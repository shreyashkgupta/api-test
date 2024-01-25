import json

def lambda_handler(event, context):
    chatbot_info = {
        "name": "My Chatbot",
        "description": "A simple chatbot for customer support",
        "language": "English",
        "creator": "John Doe"
    }
    
    return {
        "statusCode": 200,
        "body": json.dumps(chatbot_info)
    }