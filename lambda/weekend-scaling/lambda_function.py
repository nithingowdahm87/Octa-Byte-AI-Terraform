
import boto3
import json
import os

def lambda_handler(event, context):
    client = boto3.client('autoscaling')
    asg_name = os.environ['ASG_NAME']
    action = event.get('action')
    
    if action == 'scale_up':
        min_size = int(os.environ['WEEKEND_MIN'])
        desired = int(os.environ['WEEKEND_DESIRED'])
        max_size = int(os.environ['WEEKEND_MAX'])
    else:
        min_size = int(os.environ['NORMAL_MIN'])
        desired = int(os.environ['NORMAL_DESIRED'])
        max_size = int(os.environ['NORMAL_MAX'])

    client.update_auto_scaling_group(
        AutoScalingGroupName=asg_name,
        MinSize=min_size,
        MaxSize=max_size,
        DesiredCapacity=desired
    )
    
    return {"status": "success", "action": action}
