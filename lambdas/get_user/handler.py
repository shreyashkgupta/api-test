import boto3

def lambda_handler(event, context):
    # Retrieve AWS access and secret key from environment variables
    access_key = os.environ['ACCESS_KEY']
    secret_key = os.environ['SECRET_KEY']
    
    # Set up AWS client
    client = boto3.client(
        'cognito-idp',
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key,
        region_name='us-west-2'
    )
    
    # Retrieve user information
    response = client.get_user(
        AccessToken='TOKEN_HERE'
    )
    
    # Return user information
    return response