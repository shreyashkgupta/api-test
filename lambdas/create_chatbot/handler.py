import boto3

def create_chatbot():
    client = boto3.client('lex-models')
    response = client.create_bot(
        name='new_chatbot',
        description='This is a new chatbot created using Lambda function',
        intents=[
            {
                'intentName': 'GreetingIntent',
                'intentVersion': '$LATEST'
            },
            {
                'intentName': 'HelpIntent',
                'intentVersion': '$LATEST'
            },
            {
                'intentName': 'GoodbyeIntent',
                'intentVersion': '$LATEST'
            }
        ],
        clarificationPrompt={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': "I'm sorry, I didn't understand. Can you please repeat?"
                }
            ],
            'maxAttempts': 3,
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
        processBehavior='SAVE',
        locale='en-US'
    )
    print(response)

create_chatbot()