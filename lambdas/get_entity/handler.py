import json

def lambda_handler(event, context):
    entity_name = event['entity_name']
    # code to fetch details of the entity using the name
    
    # sample response
    response = {
        "entity_name": entity_name,
        "details": {
            "attribute1": "value1",
            "attribute2": "value2"
        }
    }
    
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }