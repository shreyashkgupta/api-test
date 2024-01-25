import boto3

def lambda_handler(event, context):
    
    client = boto3.client('lex-runtime')
    
    response = client.post_text(
        botName='myBot',
        botAlias='myBotAlias',
        userId='myUserId',
        inputText='Hello, my chatbot!'
    )
    
    return {
        'statusCode': 200,
        'body': response['message']
    }