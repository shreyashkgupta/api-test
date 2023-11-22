
import boto3

def lambda_handler(event, context):
    
    user_id = event['user_id']
    
    client = boto3.client('cognito-idp')
    response = client.admin_delete_user(
        UserPoolId='<USER_POOL_ID>',
        Username=user_id
    )
    
    return {
        'statusCode': 200,
        'body': 'User deleted successfully'
    }
