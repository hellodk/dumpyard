// Jenkinsfile - Declarative mobile CI optimized for Mac mini farm
pipeline {
    agent none
    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '50'))
        durabilityHint('PERFORMANCE_OPTIMIZED')
    }
    parameters {
        booleanParam(name: 'RUN_UI_TESTS', defaultValue: false, description: 'Run UI/Instrumentation tests')
    }
    environment {
        // LLM integration (configure in Jenkins credentials/environment as needed)
        LLM_ENDPOINT = "${env.LLM_ENDPOINT ?: ''}"
        LLM_API_KEY = "${env.LLM_API_KEY ?: ''}"
        ARTIFACT_STORE_URL = "${env.ARTIFACT_STORE_URL ?: ''}"
    }
    stages {
        stage('Bootstrap') {
            agent { label 'master' }
            steps {
                script {
                    metrics.startStage('bootstrap')
                    echo "Building ${env.JOB_NAME}#${env.BUILD_NUMBER} on ${env.NODE_NAME}"
                    metrics.record('agent', env.NODE_NAME ?: 'master')
                    mobileStages.checkoutWithCache()
                    mobileStages.setupEnvironment()
                    metrics.endStage('bootstrap')
                }
            }
        }

        stage('Dependencies & Static Analysis') {
            agent { label 'mac-mini' }
            steps {
                script {
                    metrics.startStage('dependencies')
                    mobileStages.dependencyCaching()
                    metrics.endStage('dependencies')

                    metrics.startStage('static-analysis')
                    mobileStages.staticAnalysis()
                    metrics.endStage('static-analysis')
                }
            }
        }

        stage('Parallel Builds & Tests') {
            agent none
            steps {
                script {
                    metrics.startStage('parallel-builds')
                    def branches = mobileStages.parallelBuilds(['android-debug','android-release','ios-debug','ios-release'])
                    if (params.RUN_UI_TESTS?.toBoolean()) {
                        branches['ui-tests'] = { node('mac-mini') { timeout(time: 30, unit: 'MINUTES') { script { metrics.startStage('ui-tests'); mobileStages.uiTests(); metrics.endStage('ui-tests') } } } }
                    }
                    parallel branches
                    metrics.endStage('parallel-builds')
                }
            }
        }

        stage('Packaging & Upload') {
            agent { label 'mac-mini' }
            steps {
                script {
                    metrics.startStage('packaging')
                    mobileStages.packageAndUpload()
                    metrics.endStage('packaging')
                }
            }
        }

        stage('Post-build Cleanup') {
            agent { label 'mac-mini' }
            steps {
                script {
                    metrics.startStage('cleanup')
                    mobileStages.cleanup()
                    metrics.endStage('cleanup')
                }
            }
        }
    }
    post {
        always {
            script {
                metrics.finalizeMetrics()
                def payload = metrics.toJsonPayload()
                writeFile file: 'metrics.json', text: payload
                archiveArtifacts artifacts: 'metrics.json', allowEmptyArchive: true
                try {
                    metrics.pushHttp(env.ARTIFACT_STORE_URL ?: '', payload)
                } catch (err) {
                    echo "Metrics push skipped or failed: ${err}"
                }
                if (env.LLM_ENDPOINT) {
                    try {
                        def insights = aiInsights.send(metrics.getSummary())
                        echo "AI insights: ${insights?.summary ?: 'none'}"
                        writeFile file: 'ai_insights.json', text: groovy.json.JsonOutput.prettyPrint(groovy.json.JsonOutput.toJson(insights))
                        archiveArtifacts artifacts: 'ai_insights.json', allowEmptyArchive: true
                    } catch (e) {
                        echo "AI insights failed: ${e.message}"
                    }
                }
            }
        }
        failure {
            script {
                metrics.recordFailure(currentBuild.rawBuild.getLog(200).join('\n'))
                metrics.finalizeMetrics()
            }
        }
    }
}
