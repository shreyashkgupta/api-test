import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    bot_name = 'your_bot_name'
    bot_version = '$LATEST'
    intent_name = 'your_intent_name'
    intent_version = '$LATEST'
    intent_slot = 'your_slot_name'
    intent_slot_type = 'your_slot_type'
    
    response = client.get_intent(
        name=intent_name,
        version=intent_version
    )
    
    response['slots'].append({
        'name': intent_slot,
        'slotType': intent_slot_type,
        'slotConstraint': 'Required',
        'valueElicitationPrompt': {
            'messages': [
                {
                    'contentType': 'PlainText',
                    'content': 'What is the value of your_slot_name?'
                }
            ],
            'maxAttempts': 2
        },
        'priority': 1,
        'sampleUtterances': []
    })
    
    response = client.put_intent(
        name=intent_name,
        slots=response['slots'],
        sampleUtterances=response['sampleUtterances'],
        confirmationPrompt=response['confirmationPrompt'],
        rejectionStatement=response['rejectionStatement'],
        followUpPrompt=response['followUpPrompt'],
        conclusionStatement=response['conclusionStatement'],
        dialogCodeHook=response['dialogCodeHook'],
        fulfillmentActivity=response['fulfillmentActivity'],
        parentIntentSignature=response['parentIntentSignature'],
        tags=response['tags']
    )
    
    return response