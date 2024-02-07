import boto3

def lambda_handler(event, context):
    client = boto3.client('iam')
    response = client.list_users()
    users = response['Users']
    while response['IsTruncated']:
        response = client.list_users(Marker=response['Marker'])
        users.extend(response['Users'])
    return {
        'statusCode': 200,
        'body': users
    }