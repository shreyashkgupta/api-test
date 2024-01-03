import json
import boto3

def lambda_handler(event, context):
    
    # Get the entity ID from the event
    entity_id = event['entity_id']
    
    # Get the new values for the entity from the event
    new_values = event['new_values']
    
    # Update the entity in the database
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('chatbot_entities')
    response = table.update_item(
        Key={
            'entity_id': entity_id
        },
        UpdateExpression='SET #vals = :new_values',
        ExpressionAttributeNames={
            '#vals': 'values'
        },
        ExpressionAttributeValues={
            ':new_values': new_values
        }
    )
    
    # Return a success message
    return {
        'statusCode': 200,
        'body': json.dumps('Entity updated successfully')
    }