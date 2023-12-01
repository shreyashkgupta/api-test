import boto3

iam = boto3.client('iam')

role_name = 'my_lambda_role'

assume_role_policy_document = {
    'Version': '2012-10-17',
    'Statement': [
        {
            'Effect': 'Allow',
            'Principal': {
                'Service': 'lambda.amazonaws.com'
            },
            'Action': 'sts:AssumeRole'
        }
    ]
}

response = iam.create_role(
    RoleName=role_name,
    AssumeRolePolicyDocument=json.dumps(assume_role_policy_document)
)

print(response)