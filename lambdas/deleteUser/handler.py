import boto3

def lambda_handler(event, context):
    user_id = event['user_id']
    
    client = boto3.client('dynamodb')
    response = client.delete_item(
        TableName='users_table',
        Key={
            'user_id': {'S': user_id}
        }
    )
    
    return {
        'statusCode': 200,
        'body': 'User deleted successfully'
    }