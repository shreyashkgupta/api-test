import boto3

def lambda_handler(event, context):
    
    iam = boto3.client('iam')
    role_name = event['role_name']
    
    response = iam.delete_role(RoleName=role_name)
    
    return {
        'statusCode': 200,
        'body': f"{role_name} has been successfully deleted"
    }