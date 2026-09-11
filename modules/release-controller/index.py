import os
import boto3
import json

elbv2 = boto3.client('elbv2')

def handler(event, context):
    listener_arn = os.environ['LISTENER_ARN']
    blue_tg_arn = os.environ['BLUE_TG_ARN']
    green_tg_arn = os.environ['GREEN_TG_ARN']
    
    weights = event.get('weights', {})
    blue_weight = weights.get('blue', 100)
    green_weight = weights.get('green', 0)
    
    if blue_weight + green_weight != 100:
        raise ValueError("Weights must sum to 100")
        
    print(f"Shifting traffic: Blue={blue_weight}, Green={green_weight}")
    
    elbv2.modify_listener(
        ListenerArn=listener_arn,
        DefaultActions=[
            {
                'Type': 'forward',
                'ForwardConfig': {
                    'TargetGroups': [
                        {'TargetGroupArn': blue_tg_arn, 'Weight': blue_weight},
                        {'TargetGroupArn': green_tg_arn, 'Weight': green_weight}
                    ]
                }
            }
        ]
    )
    
    return {"status": "success", "blue": blue_weight, "green": green_weight}
