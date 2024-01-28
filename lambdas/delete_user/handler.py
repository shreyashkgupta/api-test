import json
import boto3

def lambda_handler(event, context):
    # Create boto3 client
    client = boto3.client('cognito-idp')
    
    # Get user pool ID and username from event
    user_pool_id = event['user_pool_id']
    username = event['username']
    
    try:
        # Delete user from user pool
        response = client.admin_delete_user(
            UserPoolId=user_pool_id,
            Username=username
        )
        
        # Return success message
        return {
            'statusCode': 200,
            'body': json.dumps('User deleted successfully')
        }
    
    except Exception as e:
        # Return error message
        return {
            'statusCode': 400,
            'body': json.dumps('Error deleting user: {}'.format(str(e)))
        }