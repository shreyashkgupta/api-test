import json
import boto3

def lambda_handler(event, context):
    # Get the user ID from the event
    user_id = event['user_id']
    
    # Get the updated user information from the event
    updated_user_info = event['updated_user_info']
    
    # Create the DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    
    # Get the user table
    table = dynamodb.Table('user_table')
    
    # Update the user in the table
    response = table.update_item(
        Key={
            'user_id': user_id
        },
        UpdateExpression='SET user_info = :val1',
        ExpressionAttributeValues={
            ':val1': updated_user_info
        }
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('User updated successfully')
    }