import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('users')

def lambda_handler(event, context):
    user_id = event['user_id']
    user_data = json.loads(event['user_data'])
    response = table.update_item(
        Key={'user_id': user_id},
        UpdateExpression='SET user_data = :val1',
        ExpressionAttributeValues={':val1': user_data}
    )
    return {
        'statusCode': 200,
        'body': json.dumps('User updated successfully')
    }