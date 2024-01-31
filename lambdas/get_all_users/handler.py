import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('dynamodb')
    response = client.scan(
        TableName='users'
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response['Items']),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }