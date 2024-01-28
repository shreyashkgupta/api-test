import json
import boto3

def lambda_handler(event, context):
    
    user_id = event['user_id']
    updated_info = event['updated_info']
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('user_info_table')
    
    response = table.update_item(
        Key={
            'user_id': user_id
        },
        UpdateExpression='SET updated_info = :val1',
        ExpressionAttributeValues={
            ':val1': updated_info
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('User information updated successfully')
    }