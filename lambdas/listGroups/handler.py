import json
import boto3

def lambda_handler(event, context):
    
    iam = boto3.client('iam')
    
    response = iam.list_groups()
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }