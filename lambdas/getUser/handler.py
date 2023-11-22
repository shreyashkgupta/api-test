import json
import boto3

def lambda_handler(event, context):
    
    # create an instance of the boto3 client for the user management system
    client = boto3.client('user-management-system')
    
    # retrieve the user from the user management system
    user = client.get_user(UserId=event['userId'])
    
    # return the user as the output
    return {
        'statusCode': 200,
        'body': json.dumps(user)
    }