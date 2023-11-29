import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    group_name = event['group_name']
    user_name = event['user_name']
    
    response = iam.remove_user_from_group(
        GroupName=group_name,
        UserName=user_name
    )
    
    return response