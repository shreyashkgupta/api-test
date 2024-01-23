import json
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('UserTable')
    user_id = event['user_id']
    response = table.get_item(
        Key={
            'user_id': user_id
        }
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response['Item'])
    }