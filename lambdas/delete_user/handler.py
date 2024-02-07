import boto3

def lambda_handler(event, context):
    # Retrieve credentials from environment variables or AWS Secrets Manager
    # credentials = ...
    
    # Create an instance of the AWS SDK client
    client = boto3.client('cognito-idp', **credentials)
    
    # Extract user pool ID and username from event
    user_pool_id = event['user_pool_id']
    username = event['username']
    
    # Call the delete_user API to delete the user
    response = client.admin_delete_user(
        UserPoolId=user_pool_id,
        Username=username
    )
    
    # Return response
    return response