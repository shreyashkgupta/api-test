import json
import boto3

def lambda_handler(event, context):
    
    group_id = event['group_id']
    new_info = event['new_info']
    
    # update group info in database
    # replace the following lines with your actual code for updating the database
    db_client = boto3.client('dynamodb')
    response = db_client.update_item(
        TableName='my-groups-table',
        Key={'group_id': {'S': group_id}},
        UpdateExpression='SET info = :val1',
        ExpressionAttributeValues={':val1': {'S': new_info}}
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Group info updated successfully')
    }