import json
import boto3

def lambda_handler(event, context):
    
    chatbot_id = event['id']
    
    # Create a boto3 client for Amazon Lex Model Building Service
    lex_client = boto3.client('lex-models')
    
    # Call the get_bot() function to retrieve the chatbot
    response = lex_client.get_bot(
        name=chatbot_id,
        versionOrAlias='$LATEST'
    )
    
    # Return the chatbot details as a JSON object
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }