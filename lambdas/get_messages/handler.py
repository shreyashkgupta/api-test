import boto3

def lambda_handler(event, context):
    
    # create a client object for Amazon Connect
    connect = boto3.client('connect')
    
    # retrieve chatbot messages using Amazon Connect
    response = connect.get_transcript(
        ContactId=event['ContactId']
    )
    
    # return the chatbot messages
    return response