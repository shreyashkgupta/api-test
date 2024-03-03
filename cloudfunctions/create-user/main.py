import os
import boto3

def main(request):
    # Get credentials from environment variables
    access_key = os.environ.get('ACCESS_KEY')
    secret_key = os.environ.get('SECRET_KEY')
    region = os.environ.get('REGION')
    
    # Create client object
    client = boto3.client('cognito-idp', aws_access_key_id=access_key, aws_secret_access_key=secret_key, region_name=region)
    
    # Define parameters
    username = request.args.get('username')
    password = request.args.get('password')
    email = request.args.get('email')
    user_attributes = [
        {'Name': 'email', 'Value': email},
    ]
    
    # Create user
    response = client.sign_up(
        ClientId=os.environ.get('CLIENT_ID'),
        Username=username,
        Password=password,
        UserAttributes=user_attributes
    )
    
    # Return response
    return str(response)