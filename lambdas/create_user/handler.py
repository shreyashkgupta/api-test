import json
import boto3

def lambda_handler(event, context):

    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')

    user_id = event['user_id']
    name = event['name']
    email = event['email']

    item = {
        'user_id': user_id,
        'name': name,
        'email': email
    }

    table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': json.dumps('User created successfully')
    }