import json
import boto3

def lambda_handler(event, context):
    
    # get user id and new user info from request body
    user_id = event['pathParameters']['id']
    new_user_info = json.loads(event['body'])
    
    # update user info in database
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    response = table.update_item(
        Key={
            'user_id': user_id
        },
        UpdateExpression="set name=:n, email=:e, age=:a",
        ExpressionAttributeValues={
            ':n': new_user_info['name'],
            ':e': new_user_info['email'],
            ':a': new_user_info['age']
        },
        ReturnValues="UPDATED_NEW"
    )
    
    # return success message
    return {
        'statusCode': 200,
        'body': json.dumps('User information updated successfully')
    }