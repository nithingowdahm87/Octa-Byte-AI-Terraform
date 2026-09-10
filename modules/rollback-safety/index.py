import os
import boto3
import json

ssm = boto3.client('ssm')
lambda_client = boto3.client('lambda')

def handler(event, context):
    param_name = os.environ['DEPLOYMENT_STATE_PARAM']
    controller_func = os.environ['RELEASE_CONTROLLER_FUNC']
    
    try:
        response = ssm.get_parameter(Name=param_name)
        state = response['Parameter']['Value']
    except ssm.exceptions.ParameterNotFound:
        print("Parameter not found, ignoring.")
        return
        
    if state == "CANARY_IN_PROGRESS":
        print("Canary rollback triggered by SNS!")
        
        # Invoke release controller to set 100/0
        lambda_client.invoke(
            FunctionName=controller_func,
            InvocationType='Event',
            Payload=json.dumps({"environment": "production", "stable_weight": 100, "canary_weight": 0})
        )
        
        # Update state to ROLLED_BACK
        ssm.put_parameter(
            Name=param_name,
            Value="ROLLED_BACK",
            Type="String",
            Overwrite=True
        )
    else:
        print(f"State is {state}, no rollback needed.")
