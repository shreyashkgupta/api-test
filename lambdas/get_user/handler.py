import boto3

def lambda_handler(event, context):
    
    user_id = event['user_id']
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    
    response = table.get_item(
        Key={
            'user_id': user_id
        }
    )
    
    return response['Item']