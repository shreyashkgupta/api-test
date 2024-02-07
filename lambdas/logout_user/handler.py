import boto3
import os

def lambda_handler(event, context):
    
    # Credentials
    aws_access_key_id = os.environ['AWS_ACCESS_KEY_ID']
    aws_secret_access_key = os.environ['AWS_SECRET_ACCESS_KEY']
    
    # External Libraries
    logger = boto3.client('logs', region_name='us-east-1', aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key)
    
    # Log out user
    user_id = event['user_id']
    logger.info('User {} has been logged out.'.format(user_id))
    
    return {
        'statusCode': 200,
        'body': 'User has been logged out'
    }