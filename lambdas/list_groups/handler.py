import json
import boto3

def lambda_handler(event, context):
    
    client = boto3.client('iam')
    
    response = client.list_groups()
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }