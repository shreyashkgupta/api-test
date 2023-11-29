import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    group_name = 'my-group-name'
    user_name = event['user_name']
    
    response = iam.add_user_to_group(
        GroupName=group_name,
        UserName=user_name
    )
    
    return response