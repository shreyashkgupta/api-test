import boto3

def create_user(event, context):
    # Initialize DynamoDB client
    dynamodb = boto3.resource('dynamodb')
    
    # Get user table
    table = dynamodb.Table('user')
    
    # Create new user
    new_user = {
        'username': event['username'],
        'email': event['email'],
        'age': event['age']
    }
    
    # Add user to table
    table.put_item(Item=new_user)
    
    # Return success message
    return {
        'statusCode': 200,
        'body': 'User created successfully!'
    }