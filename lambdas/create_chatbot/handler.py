import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    
    # Define chatbot parameters
    chatbot_name = 'NewChatbot'
    chatbot_description = 'A new chatbot created using Lambda'
    chatbot_language = 'en-US'
    chatbot_intents = []
    chatbot_slots = []
    
    # Create the chatbot
    response = client.create_bot(
        name=chatbot_name,
        description=chatbot_description,
        intents=chatbot_intents,
        clarificationPrompt={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': "I'm sorry, I didn't understand. Can you please repeat that?"
                },
            ],
            'maxAttempts': 2,
        },
        abortStatement={
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, I am not able to understand. Goodbye!'
                },
            ]
        },
        idleSessionTTLInSeconds=300,
        voiceId='Joanna',
        locale=chatbot_language,
        childDirected=False,
        createVersion=False,
        processBehavior='SAVE'
    )
    
    return response