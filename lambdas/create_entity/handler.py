import json
import boto3

def lambda_handler(event, context):
    entity_name = event['entity_name']
    entity_value = event['entity_value']

    # Code to create a new entity for chatbot
    # ...

    response = {
        'statusCode': 200,
        'body': json.dumps('Entity created successfully')
    }
    return response