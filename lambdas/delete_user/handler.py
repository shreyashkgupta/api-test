import boto3

def lambda_handler(event, context):
    user_id = event['user_id']
    
    # Authenticate and authorize
    # Replace the below with your own credentials
    aws_access_key_id = 'YOUR_AWS_ACCESS_KEY_ID'
    aws_secret_access_key = 'YOUR_AWS_SECRET_ACCESS_KEY'
    region_name = 'YOUR_AWS_REGION_NAME'
    client = boto3.client('cognito-idp', 
                          aws_access_key_id=aws_access_key_id,
                          aws_secret_access_key=aws_secret_access_key,
                          region_name=region_name)
    
    # Delete the user by ID
    response = client.admin_delete_user(
        UserPoolId='YOUR_USER_POOL_ID',
        Username=user_id
    )
    
    return {
        'statusCode': 200,
        'body': 'User deleted successfully'
    }