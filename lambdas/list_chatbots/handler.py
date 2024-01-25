import json

def lambda_handler(event, context):
    chatbots = ["chatbot1", "chatbot2", "chatbot3"] # replace with actual chatbots
    return {
        'statusCode': 200,
        'body': json.dumps(chatbots)
    }