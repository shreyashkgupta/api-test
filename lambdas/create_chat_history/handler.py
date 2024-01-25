import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('chat_history')
    
    user_id = event['user_id']
    message = event['message']
    
    response = table.put_item(
        Item={
            'user_id': user_id,
            'message': message
        }
    )
    
    return {
        'statusCode': 200,
        'body': 'Chat history created successfully'
    }