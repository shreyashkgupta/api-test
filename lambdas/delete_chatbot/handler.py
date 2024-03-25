import boto3

def delete_chatbot(chatbot_name):
    client = boto3.client('lex-models')
    client.delete_bot(name=chatbot_name)