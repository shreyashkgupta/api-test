import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-runtime')
    response = client.post_text(
        botName='your_bot_name',
        botAlias='your_bot_alias',
        userId='some_user_id',
        inputText='your_message_text'
    )
    return response