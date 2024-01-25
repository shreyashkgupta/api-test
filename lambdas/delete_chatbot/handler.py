import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.delete_bot(
        name='chatbot_name'
    )
    return response