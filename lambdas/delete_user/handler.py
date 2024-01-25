import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    
    # Retrieve user information from event
    user_id = event['user_id']
    
    # Delete user from DynamoDB table
    response = table.delete_item(
        Key={
            'user_id': user_id
        }
    )
    
    return {
        'statusCode': 200,
        'body': 'User information deleted successfully'
    }