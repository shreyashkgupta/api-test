import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.get_intents()
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }