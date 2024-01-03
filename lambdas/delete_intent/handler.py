import boto3

def lambda_handler(event, context):
    
    bot_name = 'my_bot'
    intent_name = 'my_intent'
    
    client = boto3.client('lex-models')
    
    response = client.delete_intent(
        name=intent_name,
        version='$LATEST',
        checksum='string',
        createVersion=False
    )
    
    return {
        'statusCode': 200,
        'body': 'Intent deleted successfully'
    }