import json
import boto3

def lambda_handler(event, context):
    # create a DynamoDB resource
    dynamodb = boto3.resource('dynamodb')
    
    # get user ID from the event
    user_id = event['user_id']
    
    # get the users table
    table = dynamodb.Table('users')
    
    # delete the user
    response = table.delete_item(
        Key={
            'user_id': user_id
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('User deleted successfully')
    }