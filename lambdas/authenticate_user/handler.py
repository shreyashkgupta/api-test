import boto3

def lambda_handler(event, context):
    # Get credentials from AWS Secrets Manager
    secret_name = "my/secret/name"
    region_name = "us-west-2"
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    secret_value = client.get_secret_value(SecretId=secret_name)
    credentials = json.loads(secret_value['SecretString'])

    # Authenticate user
    username = event['username']
    password = event['password']
    
    if username == credentials['username'] and password == credentials['password']:
        return {"authenticated": True}
    else:
        return {"authenticated": False}