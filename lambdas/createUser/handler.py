
import json
import boto3

def lambda_handler(event, context):
    username = event['username']
    email = event['email']
    password = event['password']
    
    client = boto3.client('cognito-idp')
    
    response = client.sign_up(
        ClientId='YOUR_APP_CLIENT_ID',
        Username=username,
        Password=password,
        UserAttributes=[
            {
                'Name': 'email',
                'Value': email
            }
        ]
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
