```python
import boto3

def lambda_handler(event, context):
    user_id = event['user_id']
    
    client = boto3.client('user-management-system')
    response = client.delete_user(UserId=user_id)
    
    return {
        'statusCode': 200,
        'body': 'User deleted successfully.'
    }
```