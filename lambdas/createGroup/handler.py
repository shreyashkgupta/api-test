import boto3

def lambda_handler(event, context):
    group_name = event['group_name']
    description = event['description']

    iam = boto3.client('iam')

    response = iam.create_group(
        GroupName=group_name,
        Description=description
    )

    return {
        'statusCode': 200,
        'body': response
    }