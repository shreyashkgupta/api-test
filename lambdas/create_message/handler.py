import json
import boto3

def lambda_handler(event, context):
    message = {
        'title': 'New Message',
        'body': 'This is a new message!'
    }
    
    # save message to database or send via SQS or SNS
    
    return {
        'statusCode': 200,
        'body': json.dumps(message)
    }