import json
import boto3

def lambda_handler(event, context):
    # Create a new chatbot
    chatbot = {
        "name": "My New Chatbot",
        "description": "A chatbot created using Lambda",
        "language": "English"
    }
    
    # Save the chatbot to a database or storage service
    # For example, using AWS DynamoDB:
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('chatbots')
    table.put_item(Item=chatbot)
    
    # Return success message
    return {
        'statusCode': 200,
        'body': json.dumps('New chatbot created successfully')
    }