import boto3

def lambda_handler(event, context):
    
    client = boto3.client('logs')
    
    log_group_name = '/aws/lex/CHATBOT_NAME'
    query = 'SEARCH_QUERY'
    
    response = client.start_query(
        logGroupName=log_group_name,
        startTime=int((time.time() - 300) * 1000),
        endTime=int(time.time() * 1000),
        queryString=query,
        limit=123
    )
    
    query_id = response['queryId']
    
    return {
        'statusCode': 200,
        'body': query_id
    }