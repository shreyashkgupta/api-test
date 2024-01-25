import json
import boto3

def lambda_handler(event, context):
    
    # Extract user info from event
    username = event['username']
    email = event['email']
    
    # Create user in the system (replace with your own code)
    created_user_id = create_user(username, email)
    
    # Return response
    response = {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'User created successfully',
            'user_id': created_user_id
        })
    }
    return response

def create_user(username, email):
    # Replace with your own code to create user in the system
    return '1234'
```
Note: You will need to replace the `create_user` function with your own code for creating a user in your system.