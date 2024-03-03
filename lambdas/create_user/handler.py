import boto3

def create_user(username, password):
    iam = boto3.client('iam')
    iam.create_user(UserName=username)
    iam.create_login_profile(UserName=username, Password=password)