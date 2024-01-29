import boto3

def create_chatbot(event, context):
    
    # Create a client for Amazon Lex
    lex = boto3.client('lex-models')
    
    # Define the chatbot parameters
    chatbot_params = {
        'name': 'MyChatbot',
        'description': 'A new chatbot created using AWS Lambda and Amazon Lex',
        'intents': [],
        'clarificationPrompt': {
            'maxAttempts': 3,
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'I did not understand your message. Can you please rephrase?'
                }
            ]
        },
        'abortStatement': {
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'Sorry, I could not understand. Goodbye!'
                }
            ]
        },
        'idleSessionTTLInSeconds': 300,
        'voiceId': 'Joanna'
    }
    
    # Create the chatbot
    response = lex.put_bot(**chatbot_params)
    
    # Return the chatbot details
    return response