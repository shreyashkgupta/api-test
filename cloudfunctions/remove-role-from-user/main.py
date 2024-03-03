import os
from google.oauth2 import service_account
from googleapiclient.discovery import build

def main(request):
    # Set credentials
    credentials = service_account.Credentials.from_service_account_info(
        os.environ['GOOGLE_APPLICATION_CREDENTIALS'])

    # Set variables
    user_email = request.get_json()['user_email']
    role = request.get_json()['role']
    project_id = 'my-project-id'
    member = f'user:{user_email}'

    # Build IAM service client
    service = build('iam', 'v1', credentials=credentials)

    # Get current bindings for the project
    policy = service.projects().getIamPolicy(
        resource=f'projects/{project_id}').execute()

    # Remove role from user
    for binding in policy['bindings']:
        if binding['role'] == role and member in binding['members']:
            binding['members'].remove(member)

    # Update the policy
    update_request_body = {
        'policy': policy
    }
    response = service.projects().setIamPolicy(
        resource=f'projects/{project_id}', body=update_request_body).execute()

    # Return response
    return response