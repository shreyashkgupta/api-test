import json
import boto3

def lambda_handler(event, context):
    message_id = event['message_id']
    new_message = event['new_message']
    
    # Update message in database
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('messages')
    response = table.update_item(
        Key={
            'message_id': message_id
        },
        UpdateExpression='SET message = :val1',
        ExpressionAttributeValues={
            ':val1': new_message
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Message updated successfully!')
    }