import boto3

def lambda_handler(event, context):

    # create an IAM client
    iam = boto3.client('iam')

    # delete user
    iam.delete_user(
        UserName='USER_NAME'
    )