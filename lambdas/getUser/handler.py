import json
import boto3

def lambda_handler(event, context):
    
    # Initialize the user management system client
    client = boto3.client('user-management-system')
    
    # Retrieve user details from the user management system
    user_details = client.get_user_details()
    
    # Return the user details as a JSON object
    return {
        'statusCode': 200,
        'body': json.dumps(user_details)
    }