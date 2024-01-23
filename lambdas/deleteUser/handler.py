import boto3

def lambda_handler(event, context):
    # Initialize Boto3 client
    client = boto3.client('cognito-idp')
    
    # Get user pool ID and username from the event data
    user_pool_id = event['user_pool_id']
    username = event['username']
    
    try:
        # Delete user from user pool
        response = client.admin_delete_user(
            UserPoolId=user_pool_id,
            Username=username
        )
        return {
            'statusCode': 200,
            'body': 'User deleted successfully'
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'body': f'Error deleting user: {e}'
        }