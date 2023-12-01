import boto3

def lambda_handler(event, context):
    iam = boto3.client('iam')
    role_name = "my-role-name"
    description = "updated role description"
    iam.update_role_description(RoleName=role_name, Description=description)
    
    return {
        'statusCode': 200,
        'body': 'Role information updated successfully!'
    }