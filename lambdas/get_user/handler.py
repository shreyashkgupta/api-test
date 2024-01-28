import json

def lambda_handler(event, context):
    user_id = event['user_id'] # Assuming user_id is passed in the event
    # Your code to retrieve user information based on user_id
    user_info = {"name": "John Doe", "age": 30, "email": "johndoe@example.com"}
    return {
        'statusCode': 200,
        'body': json.dumps(user_info)
    }