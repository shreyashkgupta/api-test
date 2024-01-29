import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-runtime')
    response = client.get_session_logs(
        botName='string',
        botAlias='string',
        userId='string'
    )
    return response