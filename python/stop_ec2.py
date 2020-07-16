import boto3
'''
Enter the region your instances are in
Include only the region without specifying Availability Zone; e.g., 'us-east-1'
'''
region = 'ap-southeast-1'
# Enter your instances here: ex. ['X-XXXXXXXX', 'X-XXXXXXXX']
instances = ['i-01c98d7204fa27478']
lb = "EmpExp-LB"


def lambda_handler(event, context):
    client = boto3.client('elb')
    try:
        client.deregister_instances_from_load_balancer(
            LoadBalancerName=lb, Instances=[
                {'InstanceId': 'i-01c98d7204fa27478'}, ])
    except Exception as ex:
        print "Exception during deregister_instances_from_load_balancer ", ex
    ec2 = boto3.client('ec2', region_name=region)
    try:
        ec2.stop_instances(InstanceIds=instances)
    except Exception as ex1:
        print "Exception while shutting down instances ", instances, " ", ex1
    print 'stopped your instances: ' + str(instances)

    client = boto3.client('cloudwatch')
    client.put_metric_alarm(
        AlarmName='EmpExp-LB-HealthyHostCount',
        MetricName='HealthyHostCount',
        Namespace='AWS/ELB',
        Dimensions=[
            {
                'Name': 'LoadBalancerName',
                'Value': 'EmpExp-LB',
            },
        ],
        Period=900,
        EvaluationPeriods=1,
        DatapointsToAlarm=1,
        Threshold=1,
        ComparisonOperator='LessThanThreshold',
        Statistic='Maximum',
    )
