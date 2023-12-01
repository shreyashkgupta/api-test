import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    role_name = "YOUR_ROLE_NAME"
    response = iam.list_users_for_iam_role(RoleName=role_name)
    users = response['Users']
    for user in users:
        print(user['UserName'])