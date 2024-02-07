import boto3
from botocore.exceptions import ClientError
import json

def lambda_handler(event, context):
    
    # Set up credentials
    ACCESS_KEY = "your_access_key"
    SECRET_KEY = "your_secret_key"
    
    # Set up boto3 client
    client = boto3.client('cognito-idp',
                          aws_access_key_id=ACCESS_KEY,
                          aws_secret_access_key=SECRET_KEY,
                          region_name='your_region')
    
    # Get user attributes from event
    username = event['username']
    email = event['email']
    given_name = event['given_name']
    family_name = event['family_name']
    password = event['password']
    
    # Create user using cognito client
    try:
        response = client.admin_create_user(
            UserPoolId='your_user_pool_id',
            Username=username,
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': email
                },
                {
                    'Name': 'given_name',
                    'Value': given_name
                },
                {
                    'Name': 'family_name',
                    'Value': family_name
                },
            ],
            TemporaryPassword=password,
            MessageAction='SUPPRESS'
        )
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({
                'message': e.response['Error']['Message']
            })
        }
    
    # Return success message
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'User created successfully'
        })
    }