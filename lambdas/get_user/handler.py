import boto3

def lambda_handler(event, context):
    client = boto3.client('cognito-idp', region_name='us-west-2', aws_access_key_id='ACCESS_KEY', aws_secret_access_key='SECRET_KEY')
    
    response = client.admin_get_user(
        UserPoolId='USER_POOL_ID',
        Username=event['username']
    )
    
    return response