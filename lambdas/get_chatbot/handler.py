import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('lexv2-models')
    response = client.describe_bot(
        botId='<Bot ID>',
        botVersion='<Bot Version>'
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }