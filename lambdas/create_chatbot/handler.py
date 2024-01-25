import boto3

def lambda_handler(event, context):
    
    # Initialize variables
    bot_name = "mychatbot"
    bot_desc = "A new chatbot"
    bot_language = "en-US"
    
    # Create boto3 client for lex model building service
    lex_client = boto3.client('lex-models')
    
    # Create intent for bot
    intent_response = lex_client.create_intent(
        name='MyIntent',
        description='An intent for my chatbot',
        sampleUtterances=[
            'Hello',
            'Hi',
            'How are you?',
            'Goodbye'
        ],
        fulfillmentActivity={
            'type': 'ReturnIntent'
        }
    )
    
    # Create bot
    bot_response = lex_client.put_bot(
        name=bot_name,
        description=bot_desc,
        intents=[
            {
                'intentName': 'MyIntent',
                'intentVersion': '$LATEST'
            }
        ],
        clarificationPrompt={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'I did not understand. Can you please repeat?'
                }
            ],
            'maxAttempts': 2,
            'responseCard': 'string'
        },
        abortStatement={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, I could not understand. Goodbye!'
                }
            ]
        },
        idleSessionTTLInSeconds=123,
        voiceId='string',
        locale=bot_language
    )
    
    return bot_response