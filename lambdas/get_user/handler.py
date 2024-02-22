import boto3
import os

def lambda_handler(event, context):
    # Get user ID from input event
    user_id = event['user_id']
    
    # Initialize boto3 client for user management system
    client = boto3.client('cognito-idp')
    
    # Retrieve user from user pool
    try:
        response = client.admin_get_user(
            UserPoolId=os.environ['USER_POOL_ID'],
            Username=user_id
        )
        user = response['UserAttributes']
        return user
    except Exception as e:
        print(e)
        raise Exception('Error retrieving user from user management system')