import os
import boto3

elbv2 = boto3.client('elbv2')

def handler(event, context):
    listener_arn = os.environ['LISTENER_ARN']
    stable_tg_arn = os.environ['STABLE_TG_ARN']
    canary_tg_arn = os.environ['CANARY_TG_ARN']
    
    stable_weight = event.get('stable_weight', 100)
    canary_weight = event.get('canary_weight', 0)
    
    if stable_weight + canary_weight != 100:
        raise ValueError("Weights must sum to 100")
        
    print(f"Shifting traffic: Stable={stable_weight}, Canary={canary_weight}")
    
    elbv2.modify_listener(
        ListenerArn=listener_arn,
        DefaultActions=[
            {
                'Type': 'forward',
                'ForwardConfig': {
                    'TargetGroups': [
                        {'TargetGroupArn': stable_tg_arn, 'Weight': stable_weight},
                        {'TargetGroupArn': canary_tg_arn, 'Weight': canary_weight}
                    ]
                }
            }
        ]
    )
    
    return {"status": "success", "stable": stable_weight, "canary": canary_weight}
