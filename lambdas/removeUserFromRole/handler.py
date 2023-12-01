import boto3

iam = boto3.client('iam')

def remove_user_from_role(user_name, role_name):
    iam.remove_role_from_instance_profile(
        InstanceProfileName=role_name,
        RoleName=role_name
    )

remove_user_from_role('example_user', 'example_role')