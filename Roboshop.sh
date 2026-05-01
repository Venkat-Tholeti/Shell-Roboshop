#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0e24fb4b2e1f13c94"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z04803303VFTPZATMTQ6X"
DOMAIN_NAME="devopsaws.store"

for instance in ${INSTANCES[@]}
do  
  INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0220d79f3f480ecf5 --instance-type t3.small --security-group-ids sg-0e24fb4b2e1f13c94 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

  if [ $instance != "frontend" ]
  then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    RECORD_NAME="$instance.$DOMAIN_NAME"
  else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    RECORD_NAME="$DOMAIN_NAME"
  fi 
  echo "$instance ip address is $IP"

  aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '{
    "Comment": "Creating or Updating record",
    "Changes": [{
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [{
          "Value": "'$IP'"
        }]
      }
    }]
  }'  
done