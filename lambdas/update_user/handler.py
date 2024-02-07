import boto3

def update_user(event, context):
    # Initialize AWS client
    client = boto3.client('dynamodb')
    
    # Extract user data from event
    user_id = event['user_id']
    new_name = event['new_name']
    
    # Update user in DynamoDB table
    response = client.update_item(
        TableName='users',
        Key={
            'user_id': {'S': user_id}
        },
        UpdateExpression='SET user_name = :name',
        ExpressionAttributeValues={
            ':name': {'S': new_name}
        }
    )
    
    return response