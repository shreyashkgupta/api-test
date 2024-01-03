import boto3

def create_intent(intent_name, slots):
    client = boto3.client('lex-models')
    response = client.put_intent(
        name=intent_name,
        slots=slots
    )
    return response