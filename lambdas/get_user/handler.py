import boto3
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    user_id = event['user_id']
    # Set up credentials and connect to AWS services
    access_key = "your_access_key"
    secret_key = "your_secret_key"
    session_token = "your_session_token"
    region_name = "your_region_name"
    client = boto3.client('dynamodb', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=region_name)
    try:
        response = client.get_item(
            TableName='users',
            Key={
                'user_id': {'S': user_id}
            }
        )
        user = response['Item']
    except ClientError as e:
        print(e.response['Error']['Message'])
    return user