import boto3
from botocore.exceptions import ClientError

def create_user(username, password):
    iam = boto3.client('iam')
    try:
        response = iam.create_user(UserName=username)
        iam.create_login_profile(UserName=username, Password=password)
        print("User created successfully")
    except ClientError as e:
        print("Error creating user: ", e)

create_user('new_user', 'password')