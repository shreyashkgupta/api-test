import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.put_bot(
        name='chatbot_name',
        intents=[],
        clarificationPrompt={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'I did not understand. Can you please try again?'
                }
            ],
            'maxAttempts': 2,
            'responseCard': 'string'
        },
        abortStatement={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, I was not able to understand. Goodbye!'
                }
            ]
        },
        idleSessionTTLInSeconds=123,
        voiceId='string',
        processBehavior='SAVE'
    )
    return response