import boto3
import os

def lambda_handler(event, context):
    user_id = event['user_id']
    # Set up credentials
    ACCESS_KEY_ID = os.environ['ACCESS_KEY_ID']
    SECRET_ACCESS_KEY = os.environ['SECRET_ACCESS_KEY']
    SESSION_TOKEN = os.environ['SESSION_TOKEN']
    # Set up client
    client = boto3.client('dynamodb',
                          aws_access_key_id=ACCESS_KEY_ID,
                          aws_secret_access_key=SECRET_ACCESS_KEY,
                          aws_session_token=SESSION_TOKEN)
    # Get user by ID from DynamoDB
    response = client.get_item(
        TableName='users',
        Key={
            'user_id': {'S': user_id}
        }
    )
    return response['Item']