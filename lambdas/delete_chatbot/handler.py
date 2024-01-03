import boto3

def lambda_handler(event, context):
    bot_name = event['bot_name']
    client = boto3.client('lex-models')
    response = client.delete_bot(name=bot_name)
    return {
        'statusCode': 200,
        'body': f"Chatbot {bot_name} deleted successfully."
    }