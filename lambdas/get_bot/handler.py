import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.get_bot(
        name='chatbot-name',
        versionOrAlias='$LATEST'
    )
    return response