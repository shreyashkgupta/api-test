import boto3

def lambda_handler(event, context):
    
    bot_name = 'my_bot'
    bot_alias = 'my_alias'
    bot_intents = [
        {
            'intentName': 'greeting',
            'intentVersion': '1'
        },
        {
            'intentName': 'farewell',
            'intentVersion': '1'
        }
    ]
    
    client = boto3.client('lex-models')
    response = client.put_bot(
        name=bot_name,
        intents=bot_intents,
        checksum='ABC123',
        processBehavior='BUILD'
    )
    
    return {
        'statusCode': 200,
        'body': 'Chatbot updated successfully'
    }