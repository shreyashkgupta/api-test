```python
import boto3

def lambda_handler(event, context):
    # initialize boto3 client for user management system
    client = boto3.client('cognito-idp')

    # retrieve user from user pool
    response = client.admin_get_user(
        UserPoolId='<USER_POOL_ID>',
        Username='<USERNAME>'
    )

    # return user data
    return response
```