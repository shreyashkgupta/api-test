import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.get_bots()
    bots = response['bots']
    bot_names = [bot['name'] for bot in bots]
    return bot_names