import google.auth
from google.oauth2 import service_account
from googleapiclient import discovery

def main(user_email):
    credentials, project_id = google.auth.default(
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )
    service = discovery.build(
        "cloudresourcemanager",
        "v1",
        credentials=credentials
    )
    iam_service = discovery.build(
        "iam",
        "v1",
        credentials=credentials
    )
    user_policy = iam_service.projects().serviceAccounts().getIamPolicy(
        resource="projects/-/serviceAccounts/" + user_email
    ).execute()
    binding = next(
        b for b in user_policy["bindings"] if b["role"] == "roles/iam.serviceAccountUser"
    )
    user_members = binding["members"]
    roles = []
    for member in user_members:
        role_policy = iam_service.roles().list(
            name=member, showDeleted=False
        ).execute()
        roles += role_policy["roles"]
    return roles