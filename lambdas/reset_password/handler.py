import boto3

def reset_password(username, password):
    client = boto3.client('cognito-idp', region_name='us-west-2', aws_access_key_id='ACCESS_KEY', aws_secret_access_key='SECRET_KEY')
    response = client.admin_set_user_password(
        UserPoolId='USER_POOL_ID',
        Username=username,
        Password=password,
        Permanent=True
    )
    return response