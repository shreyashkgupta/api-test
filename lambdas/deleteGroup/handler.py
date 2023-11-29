import boto3

def lambda_handler(event, context):
    group_name = event['group_name']
    
    iam = boto3.client('iam')
    response = iam.delete_group(GroupName=group_name)
    
    return {
        'statusCode': 200,
        'body': 'Group deleted successfully'
    }