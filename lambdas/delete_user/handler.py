import boto3

def lambda_handler(event, context):
    
    # Set up AWS credentials
    AWS_ACCESS_KEY_ID = 'your_access_key_id'
    AWS_SECRET_ACCESS_KEY = 'your_secret_access_key'
    AWS_REGION = 'your_aws_region'
    
    # Set up boto3 client
    client = boto3.client('cognito-idp',
                          aws_access_key_id=AWS_ACCESS_KEY_ID,
                          aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
                          region_name=AWS_REGION)
    
    # Extract user pool id and username from event
    user_pool_id = event['user_pool_id']
    username = event['username']
    
    # Delete user from user pool
    response = client.admin_delete_user(
        UserPoolId=user_pool_id,
        Username=username
    )
    
    return {
        'statusCode': 200,
        'body': 'User deleted successfully'
    }