import boto3

def lambda_handler(event, context):
    # Get credentials from environment variables
    access_key = os.environ['ACCESS_KEY']
    secret_key = os.environ['SECRET_KEY']

    # Create client with credentials
    client = boto3.client('cognito-idp', aws_access_key_id=access_key, aws_secret_access_key=secret_key)

    # Extract user pool id and username from event
    user_pool_id = event['user_pool_id']
    username = event['username']

    # Delete user
    response = client.admin_delete_user(
        UserPoolId=user_pool_id,
        Username=username
    )

    # Return response
    return response