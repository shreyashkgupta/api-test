import google.auth
from google.oauth2 import service_account
from google.cloud import iam_v1

def main(request):
    # Replace with your service account key file path
    credentials = service_account.Credentials.from_service_account_file(
        '/path/to/service_account_key.json'
    )

    # Replace with your role name and project ID
    role_name = 'roles/editor'
    project_id = 'my-project-id'

    # Create the IAM client
    iam_client = iam_v1.IAMClient(credentials=credentials)

    # Get the existing role
    role = iam_client.get_role(
        request={
            'name': f'projects/{project_id}/roles/{role_name}'
        }
    )

    # Update the role
    role.title = 'Updated Role Title'
    updated_role = iam_client.update_role(
        request={
            'role': role,
            'update_mask': {
                'paths': ['title']
            }
        }
    )

    return 'Role updated successfully!'