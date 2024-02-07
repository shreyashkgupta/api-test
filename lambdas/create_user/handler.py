import boto3

def create_user(username, password):
    client = boto3.client('iam')
    response = client.create_user(
        UserName=username,
        Tags=[
            {
                'Key': 'Name',
                'Value': username
            },
        ]
    )
    response = client.create_login_profile(
        UserName=username,
        Password=password,
        PasswordResetRequired=False
    )
    return response