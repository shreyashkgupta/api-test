import json
import boto3

def lambda_handler(event, context):
    
    # Parse input parameters
    user_id = event['user_id']
    first_name = event['first_name']
    last_name = event['last_name']
    email = event['email']
    
    # Update user information in database
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    response = table.update_item(
        Key={
            'user_id': user_id
        },
        UpdateExpression='SET first_name = :val1, last_name = :val2, email = :val3',
        ExpressionAttributeValues={
            ':val1': first_name,
            ':val2': last_name,
            ':val3': email
        }
    )
    
    # Return response
    return {
        'statusCode': 200,
        'body': json.dumps('User information updated successfully')
    }