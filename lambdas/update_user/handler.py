import boto3

def lambda_handler(event, context):
    # Credentials for AWS
    access_key = 'ACCESS_KEY'
    secret_key = 'SECRET_KEY'
    
    # External libraries
    # import library_name
    
    # Create a boto3 client for the relevant service
    client = boto3.client('USER_SERVICE',
                          aws_access_key_id=access_key,
                          aws_secret_access_key=secret_key)
    
    # Update user
    response = client.update_user(
        user_id=event['user_id'],
        name=event['name'],
        email=event['email']
    )
    
    return response