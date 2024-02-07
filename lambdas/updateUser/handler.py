import json
import boto3

def lambda_handler(event, context):
    user_id = event['user_id']
    # Code to update user based on user_id goes here
    return {
        'statusCode': 200,
        'body': json.dumps('User updated successfully')
    }