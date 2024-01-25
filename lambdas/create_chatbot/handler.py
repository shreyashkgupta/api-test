import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.create_bot(
        name='myBot',
        description='My new chatbot',
        intents=[
            {
                'intentName': 'GreetingIntent',
                'intentVersion': '$LATEST'
            },
            {
                'intentName': 'HelpIntent',
                'intentVersion': '$LATEST'
            }
        ],
        clarificationPrompt={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, can you please repeat that?'
                }
            ],
            'maxAttempts': 3,
            'responseCard': 'string'
        },
        abortStatement={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, I cannot understand you. Goodbye!'
                }
            ]
        },
        idleSessionTTLInSeconds=123,
        voiceId='Joanna',
        processBehavior='BUILD',
        locale='en-US'
    )
    return response