import json
import boto3

def lambda_handler(event, context):
    
    # Get the chatbot information from the event
    chatbot_info = event['chatbot_info']
    
    # Update the chatbot information in the database or any other storage
    # For example, using DynamoDB
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('chatbot_table')
    
    response = table.update_item(
        Key={
            'chatbot_id': chatbot_info['id']
        },
        UpdateExpression='SET chatbot_name = :name, chatbot_description = :description',
        ExpressionAttributeValues={
            ':name': chatbot_info['name'],
            ':description': chatbot_info['description']
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Chatbot information updated successfully')
    }