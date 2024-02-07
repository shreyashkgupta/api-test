import boto3

def update_user_details(event, context):
    # get credentials from environment variables or AWS Secrets Manager
    client = boto3.client('dynamodb')
    table_name = 'users'
    user_id = event.get('user_id')
    first_name = event.get('first_name')
    last_name = event.get('last_name')
    email = event.get('email')
    
    # update user details in DynamoDB table
    response = client.update_item(
        TableName=table_name,
        Key={'user_id': {'S': user_id}},
        UpdateExpression='SET first_name = :first_name, last_name = :last_name, email = :email',
        ExpressionAttributeValues={
            ':first_name': {'S': first_name},
            ':last_name': {'S': last_name},
            ':email': {'S': email}
        }
    )
    
    return {'status': 'success', 'message': 'User details updated successfully.'}