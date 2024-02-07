import boto3

def lambda_handler(event, context):
    
    client = boto3.client('cognito-idp')
    
    response = client.admin_create_user(
        UserPoolId='your_user_pool_id',
        Username='new_user_name',
        TemporaryPassword='new_user_temp_password',
        UserAttributes=[
            {
                'Name': 'email',
                'Value': 'new_user_email@example.com'
            }
        ]
    )
    
    return response