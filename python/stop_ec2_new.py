import boto3

'''
Enter the region your instances are in
Include only the region without specifying Availability Zone; e.g., 'us-east-1'
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

'''
variables for Billing service
instances_emp_exp = [{'InstanceId': 'i-01c98d7204fa27478'}, ]
load_balancer_emp_exp = "EmpExp-LB"
# instances_emp_exp1 = ['i-01c98d7204fa27478']
dimensions_emp_exp = [
    {
        'Name': 'LoadBalancerName',
        'Value': 'EmpExp-LB',
    },
]
'''


def lambda_handler(event, context):
    '''
    Lambda Handler Method
    '''
    update_metric_alarms('EmpExp-LB-HealthyHostCount', 'HealthyHostCount',
                         'AWS/ELB', dimensions_emp_exp, 900, 1, 1, 1,
                         'LessThanThreshold', 'Maximum')
    out_of_lb(load_balancer_emp_exp, instances_emp_exp)
    shut_down_ec2(instances_emp_exp)


def shut_down_ec2(instances):
    '''
    Shuts down the EC2 machines
    '''
    list_of_instances = []
    for elem in instances:
        list_of_instances.append(elem.values()[0])
    ec2 = boto3.client('ec2', region_name=region)
    try:
        ec2.stop_instances(InstanceIds=list_of_instances)
    except Exception as ex1:
        print "Exception while shutting down instances ", instances, " ", ex1
    print 'stopped your instances: ' + str(instances)


def out_of_lb(load_balancer, instances):
    '''
    Takes the instance out of load balancer
    '''
    client = boto3.client('elb')
    try:
        client.deregister_instances_from_load_balancer(
            LoadBalancerName=load_balancer, Instances=instances)
    except Exception as ex:
        print "Exception during deregister_instances_from_load_balancer ", ex


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
