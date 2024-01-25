import boto3

def lambda_handler(event, context):
    
    # Get the chatbot information from the event
    chatbot_id = event['chatbot_id']
    chatbot_name = event['chatbot_name']
    chatbot_description = event['chatbot_description']
    
    # Update the chatbot using Amazon Lex client
    lex = boto3.client('lex-models')
    response = lex.put_bot(
        name=chatbot_name,
        description=chatbot_description,
        abort_statement={
            'messages': [
                {
                    'content': 'I don\'t understand. Can you please rephrase?',
                    'contentType': 'PlainText'
                }
            ]
        },
        idle_session_ttl_in_seconds=123,
        clarification_prompt={
            'messages': [
                {
                    'content': 'Can you please repeat that?',
                    'contentType': 'PlainText'
                }
            ],
            'maxAttempts': 3
        },
        voiceId='Joanna',
        childDirected=True,
        processBehavior='BUILD',
        locale='en-US'
    )
    
    # Return the response
    return {
        'statusCode': 200,
        'body': 'Chatbot updated successfully'
    }