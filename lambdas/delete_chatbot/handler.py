import boto3

def lambda_handler(event, context):
    chatbot_id = event['chatbot_id']
    client = boto3.client('lex-models')
    response = client.delete_bot(name=chatbot_id)
    
    return {
        'statusCode': 200,
        'body': f"Chatbot {chatbot_id} deleted successfully"
    }