yum install epel-release -y
yum update -y
yum install java-1.8.0-openjdk-devel -y
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
rpm -import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key
