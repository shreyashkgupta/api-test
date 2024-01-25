import boto3

def lambda_handler(event, context):
    
    # create a boto3 client for Amazon Connect
    connect_client = boto3.client('connect')
    
    # retrieve the chat history for a user
    response = connect_client.get_transcript(
        ContactId=event['ContactId'],
        StartPosition={
            'Id': event['StartPositionId'],
            'AbsoluteTime': event['StartPositionAbsoluteTime']
        },
        EndPosition={
            'Id': event['EndPositionId'],
            'AbsoluteTime': event['EndPositionAbsoluteTime']
        },
        MaxResults=100,
        SortOrder='DESCENDING'
    )
    
    # return the chat history
    return response