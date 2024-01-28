import json
import boto3

def lambda_handler(event, context):
    group_id = event['group_id']
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('groups')
    response = table.get_item(Key={'group_id': group_id})
    item = response['Item']
    return {
        'statusCode': 200,
        'body': json.dumps(item)
    }