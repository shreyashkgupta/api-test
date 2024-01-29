import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    bot_name = event['bot_name']
    response = client.delete_bot(name=bot_name)
    
    return {
        'statusCode': 200,
        'body': f'Chatbot {bot_name} deleted successfully.'
    }