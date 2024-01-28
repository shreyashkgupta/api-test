import json
import boto3

def lambda_handler(event, context):
    
    # create a new user in the system
    new_user = {
        "username": "example_user",
        "email": "example_user@example.com",
        "password": "example_password"
    }
    
    # save the new user to the database or user management system
    # (code for this is not provided as it will depend on the specific system being used)
    
    # return the new user information as JSON
    return {
        'statusCode': 200,
        'body': json.dumps(new_user)
    }