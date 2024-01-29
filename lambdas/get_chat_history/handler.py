import boto3

def lambda_handler(event, context):
    bot_name = "my_chatbot"
    bot_alias = "$LATEST"
    user_id = "user123"
    
    client = boto3.client('lex-runtime')
    
    response = client.get_session(
        botName=bot_name,
        botAlias=bot_alias,
        userId=user_id
    )

    return response['recentIntentSummaryView']