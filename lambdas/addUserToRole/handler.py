import boto3

def lambda_handler(event, context):

    iam = boto3.client('iam')
    response = iam.add_user_to_group(
        GroupName='your-group-name',
        UserName='your-user-name'
    )
    
    return {
        'statusCode': 200,
        'body': 'User added to group successfully!'
    }