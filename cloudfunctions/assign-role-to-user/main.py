import os
from google.cloud import iam
from google.oauth2 import service_account

def main(request):
    credentials = service_account.Credentials.from_service_account_file(os.environ['GOOGLE_APPLICATION_CREDENTIALS'])
    client = iam.IAMClient(credentials=credentials)
    user_name = request.args.get('user_name')
    role_name = request.args.get('role_name')
    parent = f'projects/{os.environ["GOOGLE_CLOUD_PROJECT"]}'
    response = client.add_iam_policy_binding(
        resource=parent,
        policy_binding={
            "role": role_name,
            "members": [f"user:{user_name}"],
        },
    )
    return response