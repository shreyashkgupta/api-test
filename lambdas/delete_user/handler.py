import boto3

def lambda_handler(event, context):
    
    # Replace with your own credentials
    session = boto3.Session(
        aws_access_key_id='ACCESS_KEY',
        aws_secret_access_key='SECRET_KEY',
        region_name='REGION'
    )
    
    # Replace 'user_table' with your table name
    dynamodb = session.resource('dynamodb').Table('user_table')
    
    # Replace 'user_id' with your own id field
    user_id = event['user_id']
    
    # Delete the user
    response = dynamodb.delete_item(
        Key={
            'user_id': user_id
        }
    )
    
    return {
        'statusCode': 200,
        'body': 'User deleted successfully'
    }