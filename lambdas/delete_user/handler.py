import boto3

def lambda_handler(event, context):

    # Retrieve the user id from the event
    user_id = event['user_id']

    # Initialize the boto3 client for Cognito
    client = boto3.client('cognito-idp')

    # Delete the user
    response = client.admin_delete_user(
        UserPoolId='YOUR_USER_POOL_ID',
        Username=user_id
    )

    # Return the response
    return response