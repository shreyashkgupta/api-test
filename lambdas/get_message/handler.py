import json

def lambda_handler(event, context):
    message = "Hello world!"
    response = {
        "statusCode": 200,
        "body": json.dumps(message)
    }
    return response