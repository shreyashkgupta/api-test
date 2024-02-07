import boto3

def lambda_handler(event, context):
    # Extract user details from event
    user_id = event['user_id']
    first_name = event['first_name']
    last_name = event['last_name']
    email = event['email']
    
    # Update user details in database
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('users')
    table.update_item(
        Key={
            'user_id': user_id
        },
        UpdateExpression='SET first_name = :first_name, last_name = :last_name, email = :email',
        ExpressionAttributeValues={
            ':first_name': first_name,
            ':last_name': last_name,
            ':email': email
        }
    )
    
    # Return success response
    return {
        'statusCode': 200,
        'body': 'User details updated successfully'
    }