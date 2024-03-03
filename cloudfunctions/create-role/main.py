import os
from google.cloud import iam
from google.cloud import functions_v1
from google.oauth2 import service_account

def main(request):
    project_id = os.environ['GCP_PROJECT']
    credentials = service_account.Credentials.from_service_account_file('credentials.json')
    client = iam.IAMCredentialsClient(credentials=credentials)
    
    role_name = 'custom_role'
    role_title = 'Custom Role'
    role_description = 'This is a custom role'

    # Define the role.
    role = {
        "title": role_title,
        "description": role_description,
        "includedPermissions": [
            "storage.objects.get",
            "storage.objects.list"
        ]
    }

    # Create the custom role.
    created_role = client.create_role(
        request={"parent": f"projects/{project_id}", "roleId": role_name, "role": role}
    )

    # Define the function.
    functions_client = functions_v1.CloudFunctionsServiceClient(credentials=credentials)
    location = 'us-central1'
    function_name = 'new_function'
    source_code = 'def main(request):\n    return "Hello World!"'
    runtime = 'python37'
    entry_point = 'main'

    # Define the function's IAM policy.
    policy = {
        "bindings": [
            {
                "role": f"projects/{project_id}/roles/{role_name}",
                "members": [
                    "allUsers"
                ],
                "condition": None
            }
        ]
    }

    # Create the function.
    created_function = functions_client.create_function(
        location=f"projects/{project_id}/locations/{location}",
        function={"name": function_name, "source_code": source_code, "entry_point": entry_point, "runtime": runtime},
        retry=None,
        timeout="60s",
        max_instances=1,
        service_account_email=None,
        available_memory_mb=256,
        labels=None,
        environment_variables=None,
        network=None,
        vpc_connector=None,
        vpc_connector_egress_settings=None,
        ingress_settings=None,
        build_environment_variables=None,
        build_network=None,
        build_vpc=None,
        build_volumes=None,
        shm_size_bytes=None,
        function_id=None,
        version_id=None,
        policy=policy
    )

    return f"Role {role_name} and function {function_name} created successfully"