import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    response = client.put_bot(
        name='my_bot',
        description='updated chatbot',
        # add any other necessary parameters here
    )
    return response