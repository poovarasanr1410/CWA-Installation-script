#!/bin/bash
 
instance_ids=("i-09d113873cec6892d") # Enter instance ID of the above instance name make sure to enter correctly
instance_names=("WordPress Server") # Enter instance names
region_name="Mumbai" # Region of the instances
region_id="ap-south-1" # Region code of the instance.
sns_arn="arn:aws:sns:ap-south-1:518863038342:MSOC" # Enter SNS ARN
customer_name="LANGUAGEVEDA SCHOOL" # Enter Customer name
warn_threshold=80
crit_threshold=90
 
############ DO NOT EDIT BELOW ###############
 
# Iterate over instance names and IDs
for ((i=0; i<${#instance_names[@]}; i++)); do
  instance_name="${instance_names[$i]}"
  instance_id="${instance_ids[$i]}"
 
  # Get instance type of each individual instance
  instance_type=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[].Instances[].InstanceType' --output text)
  echo "Type of this $instance_name : $instance_type"
 
  # Get instance image id
  image_id=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[].Instances[].ImageId' --output text)
  echo "Image ID of this $instance_name : $image_id"
 
  # Alarm for instance check fail with action reboot
  aws cloudwatch put-metric-alarm --alarm-name "[CRIT]$customer_name[$region_name][$instance_name] InstanceStatusCheckFailed" --alarm-description "Alarm for EC2 instance status check failures" --metric-name StatusCheckFailed_Instance --namespace AWS/EC2 --statistic Maximum --period 60 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=InstanceId,Value=$instance_id" --evaluation-periods 1 --actions-enabled --alarm-actions "arn:aws:automate:$region_id:ec2:reboot" "${sns_arn}"
 
  echo "Created alarm: [CRIT]$customer_name[$region_name][$instance_name] InstanceStatusCheckFailed with reboot action"
 
  # Alarm for System check fail with action recover
  aws cloudwatch put-metric-alarm --alarm-name "[CRIT]$customer_name[$region_name][$instance_name] SystemStatusCheckFailed" --alarm-description "Alarm for EC2 instance status check failures" --metric-name StatusCheckFailed_System --namespace AWS/EC2 --statistic Maximum --period 60 --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=InstanceId,Value=$instance_id" --evaluation-periods 1 --actions-enabled --alarm-actions "arn:aws:automate:$region_id:ec2:recover" "${sns_arn}"
 
  echo "Created alarm: [CRIT]$customer_name[$region_name][$instance_name] SystemStatusCheckFailed with recover action"
 
  # Alarm for CPUUtilization WARN
  aws cloudwatch put-metric-alarm --alarm-name "[WARN]$customer_name[$region_name][$instance_name] CPU Utilization [>=$warn_threshold]" --alarm-description "Alarm for EC2 instance CPU Utilization" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold $warn_threshold --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=InstanceId,Value=$instance_id" --evaluation-periods 1 --actions-enabled --alarm-actions "${sns_arn}"
 
  echo "Created alarm: [WARN]$customer_name[$region_name][$instance_name] CPU Utilization [>=$warn_threshold]"
 
  # Alarm for CPUUtilization CRIT
  aws cloudwatch put-metric-alarm --alarm-name "[CRIT]$customer_name[$region_name][$instance_name] CPU Utilization [>=$crit_threshold]" --alarm-description "Alarm for EC2 instance CPU Utilization" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold $crit_threshold --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=InstanceId,Value=$instance_id" --evaluation-periods 1 --actions-enabled --alarm-actions "${sns_arn}"
 
  echo "Created alarm: [CRIT]$customer_name[$region_name][$instance_name] CPU Utilization [>=$crit_threshold]"
 
  # Alarm for MemoryUtilization WARN
  aws cloudwatch put-metric-alarm --alarm-name "[WARN]$customer_name[$region_name][$instance_name] Memory Utilization [>=$warn_threshold]" --alarm-description "Alarm for EC2 instance Memory Utilization" --metric-name mem_used_percent --namespace CWAgent --statistic Average --period 300 --threshold $warn_threshold --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=InstanceId,Value=$instance_id" "Name=ImageId,Value=$image_id" "Name=InstanceType,Value=$instance_type" --evaluation-periods 1 --actions-enabled --alarm-actions "${sns_arn}"
 
  echo "Created alarm: [WARN]$customer_name[$region_name][$instance_name] Memory Utilization [>=$warn_threshold]"
 
  # Alarm for MemoryUtilization CRIT
  aws cloudwatch put-metric-alarm --alarm-name "[CRIT]$customer_name[$region_name][$instance_name] Memory Utilization [>=$crit_threshold]" --alarm-description "Alarm for EC2 instance Memory Utilization" --metric-name mem_used_percent --namespace CWAgent --statistic Average --period 300 --threshold $crit_threshold --comparison-operator GreaterThanOrEqualToThreshold --dimensions "Name=InstanceId,Value=$instance_id" "Name=ImageId,Value=$image_id" "Name=InstanceType,Value=$instance_type" --evaluation-periods 1 --actions-enabled --alarm-actions "${sns_arn}"
 
  echo "Created alarm: [CRIT]$customer_name[$region_name][$instance_name] Memory Utilization [>=$crit_threshold]"
 
done