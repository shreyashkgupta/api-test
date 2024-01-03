import boto3

def lambda_handler(event, context):
    client = boto3.client('lex-models')
    
    # Get the entity name from the input event
    entity_name = event['entity_name']
    
    # Delete the entity
    response = client.delete_entity(
        name=entity_name,
        version='$LATEST'
    )
    
    return {
        'statusCode': 200,
        'body': 'Entity {} deleted successfully'.format(entity_name)
    }