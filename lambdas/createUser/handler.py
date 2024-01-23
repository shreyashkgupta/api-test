import json
import boto3

def lambda_handler(event, context):
    
    # get user details from the event
    user = json.loads(event['body'])
    
    # create a new user in the user management system
    # replace this code with your own user management system code
    # for example, you could use AWS Cognito or a custom database
    create_user(user)
    
    # return a success response
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "User created successfully"})
    }
    
    return response

def create_user(user):
    # replace this code with your own user management system code
    # for example, you could use AWS Cognito or a custom database
    print("Creating user:", user)