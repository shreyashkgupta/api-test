import boto3
from botocore.exceptions import ClientError

def create_new_user(username, password):
    client = boto3.client('iam')
    try:
        response = client.create_user(
            UserName=username
        )
        response = client.create_login_profile(
            UserName=username,
            Password=password,
            PasswordResetRequired=True
        )
        return response
    except ClientError as e:
        print(e)
        return None