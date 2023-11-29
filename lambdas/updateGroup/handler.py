import json
import boto3

def lambda_handler(event, context):
    # extract group details from the event payload
    group_id = event['group_id']
    group_name = event['group_name']
    group_members = event['group_members']

    # update the group details in the database
    db = boto3.resource('dynamodb')
    table = db.Table('group_details')
    response = table.update_item(
        Key={
            'group_id': group_id
        },
        UpdateExpression='SET group_name = :name, group_members = :members',
        ExpressionAttributeValues={
            ':name': group_name,
            ':members': group_members
        },
        ReturnValues='UPDATED_NEW'
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Group details updated successfully')
    }