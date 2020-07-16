import boto3

aws_access_key_id = "XXXXXXXXXXXXXXXXXXXX"
aws_secret_access_key = "XXXXXXXXXXXXX"

region = 'ap-southeast-1'
ec2 = boto3.resource(
    'ec2', region,
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key)
instances = ec2.instances.filter()
for instance in instances:
    print instance.public_ip_address
