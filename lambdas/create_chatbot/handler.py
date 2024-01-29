import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.create_bot(
        name='MyChatBot',
        description='My new chatbot',
        intents=[
            {
                'intentName': 'GreetingIntent',
                'intentVersion': '$LATEST'
            },
            {
                'intentName': 'GoodbyeIntent',
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
                    'content': "I'm sorry, I didn't understand. Can you please repeat that?"
                }
            ],
            'maxAttempts': 3
        },
        abortStatement={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, I cannot understand you.'
                }
            ]
        },
        idleSessionTTLInSeconds=300,
        voiceId='Joanna',
        processBehavior='BUILD'
    )
    return response