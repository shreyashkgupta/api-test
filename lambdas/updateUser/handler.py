```
import json
import boto3

def lambda_handler(event, context):
    # Extract required inputs from the event
    user_id = event['user_id']
    updated_user_data = event['updated_user_data']

    # Update the user in the user management system
    client = boto3.client('user-management-system')
    response = client.update_user(
        user_id=user_id,
        updated_user_data=updated_user_data
    )

    # Return the updated user details
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
```