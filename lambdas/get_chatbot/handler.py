import boto3

def lambda_handler(event, context):
    chatbot_id = event['chatbot_id']
    
    # Replace 'region_name' with the AWS region where your chatbot is deployed
    client = boto3.client('lexv2-models', region_name='us-west-2')
    
    response = client.describe_bot(botId=chatbot_id)
    
    return response