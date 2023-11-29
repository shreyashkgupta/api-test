import json

def lambda_handler(event, context):
    # TODO implement
    group_name = event['group_name']
    group_details = {
        'name': group_name,
        'members': ['John', 'Jane', 'Bob']
    }
    return {
        'statusCode': 200,
        'body': json.dumps(group_details)
    }