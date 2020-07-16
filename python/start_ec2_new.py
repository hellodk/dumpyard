import boto3
'''
Enter the region your instances are in
Include only the region without specifying Availability Zone; e.g.; 'us-east-1'
'''

'''
GLOBAL VARIABLES
'''
region = 'ap-southeast-1'

'''
variables for employye experience service
'''
instances_emp_exp = [{'InstanceId': 'i-01c98d7204fa27478'}, ]
load_balancer_emp_exp = "EmpExp-LB"
# instances_emp_exp1 = ['i-01c98d7204fa27478']
dimensions_emp_exp = [
    {
        'Name': 'LoadBalancerName',
        'Value': 'EmpExp-LB',
    },
]


def lambda_handler(event, context):
    start_ec2(instances_emp_exp)
    add_to_load_balancer(load_balancer_emp_exp, instances_emp_exp)
    update_metric_alarms('EmpExp-LB-HealthyHostCount', 'HealthyHostCount',
                         'AWS/ELB', dimensions_emp_exp, 900, 1, 1, 2,
                         'LessThanThreshold', 'Maximum')


def start_ec2(instances):
    '''
    Starts the provided list of EC2 machines
    '''
    list_of_instances = []
    for elem in instances:
        list_of_instances.append(elem.values()[0])
    ec2 = boto3.client('ec2', region_name=region)
    try:
        ec2.start_instances(InstanceIds=list_of_instances)
    except Exception as ex1:
        print "Exception while starting the instance ", instances, " ", ex1
    print 'started your instances: ' + str(instances)


def add_to_load_balancer(load_balancer, instances):
    '''
    Adds the machine to the specified load balancers
    '''
    client = boto3.client('elb')
    try:
        client.register_instances_with_load_balancer(
            LoadBalancerName=load_balancer, Instances=instances)
    except Exception as ex:
        print "Caught in exception while adding instance to LB", ex


def update_metric_alarms(alarm_name, metric_name, namespace,
                         dimensions_emp_exp, period, evaluation_periods,
                         datapoints_to_alarm, threshold, comparison_operator,
                         statistics):
    '''
    Updates the metric alarms
    '''
    client = boto3.client('cloudwatch')
    client.put_metric_alarm(
        AlarmName=alarm_name,
        MetricName=metric_name,
        Namespace=namespace,
        Dimensions=dimensions_emp_exp,
        Period=period,
        EvaluationPeriods=evaluation_periods,
        DatapointsToAlarm=datapoints_to_alarm,
        Threshold=threshold,
        ComparisonOperator=comparison_operator,
        Statistic=statistics,
    )
