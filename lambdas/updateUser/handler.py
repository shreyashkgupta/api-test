import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('user')

def lambda_handler(event, context):
    user_id = event['user_id']
    first_name = event['first_name']
    last_name = event['last_name']
    email = event['email']
    
    table.update_item(
        Key={
            'user_id': user_id
        },
        UpdateExpression='SET first_name=:f, last_name=:l, email=:e',
        ExpressionAttributeValues={
            ':f': first_name,
            ':l': last_name,
            ':e': email
        }
    )
    
    return {
        'statusCode': 200,
        'body': 'User information updated successfully'
    }