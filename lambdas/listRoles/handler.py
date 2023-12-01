import json
import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    roles = iam.list_roles()
    return {
        'statusCode': 200,
        'body': json.dumps(roles['Roles'])
    }