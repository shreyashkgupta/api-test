import boto3

def lambda_handler(event, context):
    # Retrieve the necessary parameters from the event
    username = event['username']
    password = event['password']
    email = event['email']

    # Initialize the AWS Cognito client
    cognito = boto3.client('cognito-idp')

    # Create the new user
    response = cognito.sign_up(
        ClientId='<your_client_id>',
        Username=username,
        Password=password,
        UserAttributes=[
            {
                'Name': 'email',
                'Value': email
            }
        ]
    )

    # Return the newly created user's details
    return {
        'statusCode': 200,
        'body': response
    }