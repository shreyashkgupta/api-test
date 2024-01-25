import boto3

def lambda_handler(event, context):
    
    # Create a client for the Amazon Lex Model Building Service
    lex_client = boto3.client('lex-models')
    
    # Update the chatbot with the new data
    response = lex_client.put_bot(
        name='MyChatBot',
        intents=[
            {
                'intentName': 'GreetingIntent',
                'intentVersion': '$LATEST'
            },
            {
                'intentName': 'FarewellIntent',
                'intentVersion': '$LATEST'
            }
        ],
        clarificationPrompt={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'I did not understand. Can you please rephrase your question?'
                }
            ],
            'maxAttempts': 2,
            'responseCard': 'None'
        },
        abortStatement={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, I could not understand. Goodbye!'
                }
            ]
        }
    )
    
    # Return the response
    return {
        'statusCode': 200,
        'body': response
    }