import boto3

def lambda_handler(event, context):
    # Initialize boto3 dynamodb client
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('user')

    # Delete user's information from the user table
    response = table.delete_item(
        Key={
            'user_id': event['user_id']
        }
    )

    # Return response
    return {
        'statusCode': 200,
        'body': 'User information deleted successfully'
    }