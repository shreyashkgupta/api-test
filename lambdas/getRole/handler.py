import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    role_name = 'your_role_name'
    role = iam.get_role(RoleName=role_name)
    return role