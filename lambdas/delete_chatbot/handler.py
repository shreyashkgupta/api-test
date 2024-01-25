import boto3

def lambda_handler(event, context):
    # Create boto3 client for Lex Model Building Service
    lex_client = boto3.client('lex-models')
    
    # Delete chatbot using the provided bot name
    bot_name = event['bot_name']
    lex_client.delete_bot(name=bot_name)
    
    # Return success message
    return {
        'statusCode': 200,
        'body': 'Chatbot deleted successfully'
    }