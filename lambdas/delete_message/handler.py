import boto3

def lambda_handler(event, context):
    
    sqs = boto3.client('sqs')
    queue_url = 'QUEUE_URL_HERE'
    
    response = sqs.receive_message(
        QueueUrl=queue_url,
        AttributeNames=['All'],
        MaxNumberOfMessages=1,
        VisibilityTimeout=0,
        WaitTimeSeconds=0
    )
    
    if 'Messages' in response:
        message = response['Messages'][0]
        receipt_handle = message['ReceiptHandle']
        
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        
        return {
            'statusCode': 200,
            'body': 'Message deleted successfully'
        }
    else:
        return {
            'statusCode': 404,
            'body': 'No messages found in the queue'
        }