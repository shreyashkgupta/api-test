import json
import boto3

def lambda_handler(event, context):
    user_id = event['user_id']
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Users')
    table.delete_item(
        Key={
            'user_id': user_id
        }
    )
    return {
        'statusCode': 200,
        'body': json.dumps('User deleted successfully')
    }