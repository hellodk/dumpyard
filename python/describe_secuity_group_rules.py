import boto3

ec2 = boto3.client('ec2',region_name='ap-south-1')
response = ec2.describe_security_groups()

for i in response['SecurityGroups']:
   print ("Security Group Name: "+ i['GroupName'])
   print ("the Egress rules are as follows: ")
   for j in i['IpPermissionsEgress']:
      print ("IP Protocol: "+ j['IpProtocol'])
      for k in j['IpRanges']:
         print ("IP Ranges: "+ k['CidrIp'])
   print ("The Ingress rules are as follows: ")
   for j in i['IpPermissions']:
      print ("IP Protocol: "+ j['IpProtocol'])
      try:
         print ("PORT: "+str(j['FromPort']))
         for k in j['IpRanges']:
            print ("IP Ranges: "+ k['CidrIp'])
      except Exception as ex:
         print ("No value for ports and ip ranges available for this security group")
         continue