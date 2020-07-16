import boto3
'''
Enter the region your instances are in
Include only the region without specifying Availability Zone; e.g.; 'us-east-1'
'''
region = 'ap-southeast-1'
# Enter your instances here: ex. ['X-XXXXXXXX', 'X-XXXXXXXX']
instances = ['i-01c98d7204fa27478']
lb = "EmpExp-LB"


def lambda_handler(event, context):
    client = boto3.client('elb')
    try:
        client.register_instances_with_load_balancer(
            LoadBalancerName=lb, Instances=[
                {'InstanceId': 'i-01c98d7204fa27478'}, ])
    except Exception as ex:
        print "Caught in exception ", ex
    ec2 = boto3.client('ec2', region_name=region)
    try:
        ec2.start_instances(InstanceIds=instances)
    except Exception as ex1:
        print "Caught in exception whule starting instances ", ex1
    print 'started your instances: ' + str(instances)

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
        Threshold=2,
        ComparisonOperator='LessThanThreshold',
        Statistic='Maximum',
    )
