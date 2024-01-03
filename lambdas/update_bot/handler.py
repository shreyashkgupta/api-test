import boto3

def lambda_handler(event, context):
    bot_name = event['bot_name']
    bot_alias = event['bot_alias']
    intent_name = event['intent_name']
    intent_data = event['intent_data']
    
    client = boto3.client('lex-models')
    
    response = client.put_intent(
        name=intent_name,
        description='Intent for updating a chatbot',
        slots=[],
        sampleUtterances=[],
        conclusionStatement={},
        dialogCodeHook={},
        fulfillmentActivity={},
        parentIntentSignature='',
        createVersion=False,
        checksum=''
    )
    
    return {
        'statusCode': 200,
        'body': response
    }