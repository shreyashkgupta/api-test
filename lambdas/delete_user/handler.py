import json
import boto3

def lambda_handler(event, context):
    user_id = event['user_id']
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    
    table.delete_item(
        Key={
            'user_id': user_id
        }
    )
    
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "User deleted successfully"})
    }
    
    return response