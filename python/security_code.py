import boto3 
ec2 = boto3.client('ec2',region_name='ap-south-1')
response = ec2.describe_security_groups()

type(response)
print (response.keys()
meta = response['ResponseMetadata']
data = response['data']


