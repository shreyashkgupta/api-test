import boto3

def lambda_handler(event, context):
    
    client = boto3.client('lex-models')
    
    bot_name = 'myBot'
    bot_version = '$LATEST'
    
    # Update the bot
    response = client.put_bot(
        name=bot_name,
        versionOrAlias=bot_version,
        **add your update parameters here**
    )
    
    return response