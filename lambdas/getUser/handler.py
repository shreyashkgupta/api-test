
import boto3

def lambda_handler(event, context):
    user_id = event['user_id'] # assuming user_id is passed in as an event parameter
    client = boto3.client('user-management-system') # replace with actual client name
    response = client.get_user(UserId=user_id)
    return response
