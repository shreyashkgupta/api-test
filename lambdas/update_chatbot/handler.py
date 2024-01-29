import boto3

def lambda_handler(event, context):
    
    # Initialize the Amazon Lex runtime client
    lex = boto3.client('lex-runtime')
    
    # Get the input message from the event
    message = event['message']
    
    # Call the Amazon Lex update_bot API to update the chatbot
    response = lex.update_bot(
        botId='<BOT_ID>',
        botName='<BOT_NAME>',
        description='<BOT_DESCRIPTION>',
        roleArn='<ROLE_ARN>',
        dataPrivacy={'childDirected': False},
        idleSessionTTLInSeconds=300,
        conversationLogs={
            'logSettings': [
                {
                    'logType': 'AUDIO',
                    'destination': 'CLOUDWATCH_LOGS',
                    'logLevel': 'INFO'
                },
                {
                    'logType': 'TEXT',
                    'destination': 'CLOUDWATCH_LOGS',
                    'logLevel': 'INFO'
                }
            ]
        }
    )
    
    # Return the response from the Amazon Lex update_bot API
    return response