import boto3

def lambda_handler(event, context):
    
    user_id = event['user_id']
    
    # Code to delete user with user_id from user management system
    # Replace with your own implementation
    
    return {
        'statusCode': 200,
        'body': 'User deleted successfully'
    }