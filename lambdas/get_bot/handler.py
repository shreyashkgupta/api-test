import json

def lambda_handler(event, context):
    
    bot_id = event["bot_id"] # assuming bot_id is a required parameter passed in the event
    # code to get chatbot details using bot_id
    chatbot_details = {"id": bot_id, "name": "Sample Bot", "description": "This is a sample chatbot."}
    
    response = {
        "statusCode": 200,
        "body": json.dumps(chatbot_details)
    }
    
    return response