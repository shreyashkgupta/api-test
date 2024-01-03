import json

def lambda_handler(event, context):
    entities = [
        {
            "name": "entity1",
            "value": "value1"
        },
        {
            "name": "entity2",
            "value": "value2"
        },
        {
            "name": "entity3",
            "value": "value3"
        }
    ]
    
    return {
        'statusCode': 200,
        'body': json.dumps(entities)
    }