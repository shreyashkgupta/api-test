```python
import json
import boto3

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')
    response = client.admin_create_user(
        UserPoolId='your_user_pool_id',
        Username='new_user_username',
        TemporaryPassword='temporary_password',
        UserAttributes=[
            {
                'Name': 'email',
                'Value': 'new_user_email@example.com'
            },
            {
                'Name': 'phone_number',
                'Value': '+1234567890'
            },
        ],
        DesiredDeliveryMediums=[
            'EMAIL',
        ]
    )
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
```