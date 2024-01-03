import boto3

client = boto3.client('lex-models')

def lambda_handler(event, context):
    response = client.put_intent(
        name='ExistingIntentName',
        description='Updated intent description',
        sampleUtterances=[
            'New sample utterance'
        ],
        dialogCodeHook={
            'uri': 'dialog_lambda_function_ARN',
            'messageVersion': '1.0'
        },
        fulfillmentActivity={
            'type': 'ReturnIntent'
        }
    )
    return response