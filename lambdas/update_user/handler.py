import boto3

def lambda_handler(event, context):
    # Initialize Boto3 client
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')

    # Get user ID from event
    user_id = event['user_id']

    # Get updated user info from event
    updated_user_info = event['updated_user_info']

    # Update user info in DynamoDB table
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
        'body': 'User information updated successfully'
    }