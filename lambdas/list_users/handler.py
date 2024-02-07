import boto3

def lambda_handler(event, context):
    # Add your AWS credentials here
    access_key = 'YOUR_ACCESS_KEY'
    secret_key = 'YOUR_SECRET_KEY'

    # Create a boto3 client to interact with AWS services
    client = boto3.client('iam', aws_access_key_id=access_key, aws_secret_access_key=secret_key)

    # List all the users
    response = client.list_users()

    # Extract the user details from the response
    users = response['Users']

    # Print the user details
    for user in users:
        print(user['UserName'])