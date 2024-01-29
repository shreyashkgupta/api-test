import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-runtime')
    response = client.post_text(
        botName='YourBotName',
        botAlias='YourBotAlias',
        userId='YourUserID',
        inputText='YourMessage'
    )
    return response['message']