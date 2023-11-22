
import json
import boto3

def lambda_handler(event, context):
    # Parse input parameters
    user_id = event['userId']
    user_data = event['userData']

    # Update user in user management system
    client = boto3.client('user-management')
    response = client.update_user(
        UserId=user_id,
        UserData=user_data
    )

    # Return updated user data
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
