import json
import boto3

def lambda_handler(event, context):
    username = event['username']
    email = event['email']
    password = event['password']
    
    # Code to create new user using the input parameters
    
    response = {
        'statusCode': 200,
        'body': json.dumps('User created successfully')
    }
    
    return response