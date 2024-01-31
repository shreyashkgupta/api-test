import json

def lambda_handler(event, context):
    # Get user details from database or any other source
    user_details = {
        "name": "John Doe",
        "email": "johndoe@example.com",
        "phone": "+1 (555) 555-5555"
    }
    
    # Convert user details to JSON format
    user_details_json = json.dumps(user_details)
    
    # Return user details as response
    return {
        'statusCode': 200,
        'body': user_details_json
    }