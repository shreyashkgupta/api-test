import boto3

def lambda_handler(event, context):
    client = boto3.client('iam')
    response = client.list_users()
    for user in response['Users']:
        print(user['UserName'])