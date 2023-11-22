
import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')
    response = client.list_users(
        UserPoolId='<USER_POOL_ID>'
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
```

Note: Replace `<USER_POOL_ID>` with the actual User Pool ID of your user management system.