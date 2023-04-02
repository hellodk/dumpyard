#!/bin/bash

group_id="sg-0c4f83a88f42f1d9a";
port="22";

curl wgetip.com > ip.txt
awk '{ print $0 "/32" }' < ip.txt > ipfull.txt
export foo=$(cat ipfull.txt)
aws ec2 authorize-security-group-ingress --region=ap-south-1 \
    --group-id $group_id \
    --ip-permissions IpProtocol=tcp,FromPort=$port,ToPort=$port,IpRanges="[{CidrIp=${foo},Description='dk home public IP'}]"


# aws ec2 describe-security-groups --filter Name=group-name,Values=default --output json | jq -r .SecurityGroups[].GroupId