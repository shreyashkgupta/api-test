import json

def lambda_handler(event, context):
    # Retrieve user information
    user_info = {
        "name": "John Doe",
        "email": "johndoe@example.com",
        "age": 30,
        "location": "New York"
    }
    
    # Return user information as JSON
    return {
        'statusCode': 200,
        'body': json.dumps(user_info)
    }