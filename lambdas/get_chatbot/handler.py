import boto3

def lambda_handler(event, context):
    # Get credentials from environment variables
    access_key = os.environ['ACCESS_KEY']
    secret_key = os.environ['SECRET_KEY']

    # Create a session
    session = boto3.Session(
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key
    )

    # Create a client for Amazon Lex Model Building Service
    client = session.client('lex-models')

    # Retrieve chatbot details
    bot_name = event['bot_name']
    bot_version = event['bot_version']
    response = client.get_bot(
        name=bot_name,
        versionOrAlias=bot_version
    )

    return response