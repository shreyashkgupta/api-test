import json

def lambda_handler(event, context):
    intent_name = event['currentIntent']['name']
    intent_slots = event['currentIntent']['slots']

    # Add your code to retrieve details of the intent

    response = {
        "dialogAction": {
            "type": "Close",
            "fulfillmentState": "Fulfilled",
            "message": {
                "contentType": "PlainText",
                "content": "Here are the details of the {} intent: {}".format(intent_name, json.dumps(intent_slots))
            }
        }
    }

    return response