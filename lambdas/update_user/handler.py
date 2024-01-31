import json
import boto3

def lambda_handler(event, context):
    
    # extract user id and details from the request body
    user_id = event['pathParameters']['id']
    user_details = json.loads(event['body'])
    
    # update user details in the database
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    response = table.update_item(
        Key={
            'id': user_id
        },
        UpdateExpression='SET name = :name, email = :email',
        ExpressionAttributeValues={
            ':name': user_details['name'],
            ':email': user_details['email']
        }
    )
    
    # return success message
    return {
        'statusCode': 200,
        'body': json.dumps('User details updated successfully')
    }