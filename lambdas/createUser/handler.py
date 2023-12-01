import json
import boto3

def lambda_handler(event, context):
    # Get the request body
    request_body = json.loads(event['body'])
    
    # Extract the user information
    user_name = request_body['user_name']
    email = request_body['email']
    password = request_body['password']
    
    # Create a new user in your app's user database
    # ...

    # Return the response
    response = {
        'statusCode': 200,
        'body': json.dumps({'message': f'User {user_name} created successfully'})
    }
    
    return response