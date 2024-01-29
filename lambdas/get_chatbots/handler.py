import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    bots = client.get_bots()["bots"]
    return {
        'statusCode': 200,
        'body': json.dumps(bots)
    }