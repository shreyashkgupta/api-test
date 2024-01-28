import json
import boto3

def lambda_handler(event, context):
    groupName = event['groupName']
    ec2 = boto3.client('ec2')
    response = ec2.delete_security_group(
        GroupName=groupName
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Security Group ' + groupName + ' deleted successfully')
    }