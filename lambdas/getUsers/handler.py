import json
import boto3

def lambda_handler(event, context):

    # Create the DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    
    # Select the user table
    table = dynamodb.Table('user')
    
    # Scan the table to retrieve all users
    response = table.scan()
    
    # Return the list of users
    return {
        'statusCode': 200,
        'body': json.dumps(response['Items'])
    }