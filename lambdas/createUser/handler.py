import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')
    response = client.admin_create_user(
        UserPoolId='your_user_pool_id',
        Username='new_user',
        UserAttributes=[
            {
                'Name': 'email',
                'Value': 'user@example.com'
            },
        ],
        TemporaryPassword='temporary_password',
        MessageAction='SUPPRESS'
    )
    return {
        'statusCode': 200,
        'body': json.dumps('User created successfully')
    }