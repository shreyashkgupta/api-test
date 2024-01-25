import json
import boto3

def lambda_handler(event, context):
    
    # Get chatbot information from event
    chatbot_info = json.loads(event['body'])
    chatbot_id = chatbot_info['chatbot_id']
    updated_info = chatbot_info['updated_info']
    
    # Update chatbot
    client = boto3.client('lex-models')
    response = client.update_bot(
        name=chatbot_id,
        **updated_info
    )
    
    # Return response
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }