import json

def lambda_handler(event, context):
    user_id = event['user_id']
    # code to retrieve user details using user_id
    user_details = {
        'name': 'John Doe',
        'email': 'johndoe@example.com',
        'age': 30
    }
    response = {
        'statusCode': 200,
        'body': json.dumps(user_details)
    }
    return response