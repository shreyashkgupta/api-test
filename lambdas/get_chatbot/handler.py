import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    bot_name = 'your_bot_name'
    bot_version = '$LATEST'
    response = client.get_bot(
        name=bot_name,
        versionOrAlias=bot_version
    )
    return response