import json

def lambda_handler(event, context):
    user_id = event["userId"]
    user_name = "John Doe"
    user_email = "johndoe@example.com"
    user_info = {"userId": user_id, "userName": user_name, "userEmail": user_email}
    return {
        'statusCode': 200,
        'body': json.dumps(user_info)
    }