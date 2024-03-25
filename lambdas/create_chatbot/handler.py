import boto3

def lambda_handler(event, context):
    # Authenticate with external service
    client = boto3.client('external-service', 
                          aws_access_key_id='ACCESS_KEY', 
                          aws_secret_access_key='SECRET_KEY')
    
    # Create new chatbot
    chatbot = client.create_chatbot()
    
    # Return chatbot details
    return chatbot