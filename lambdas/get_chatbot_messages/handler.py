import boto3

def lambda_handler(event, context):
    
    client = boto3.client('lex-runtime')
    
    response = client.get_session(
        botAlias='string',
        botName='string',
        userId='string'
    )
    
    messages = response['recentIntentSummaryView']
    
    return messages