import boto3

def lambda_handler(event, context):
    
    client = boto3.client('lex-runtime')
    response = client.post_text(
        botName='your_bot_name',
        botAlias='your_bot_alias',
        userId='your_user_id',
        inputText=event['input']
    )
    
    return {
        'statusCode': 200,
        'body': response['message']
    }