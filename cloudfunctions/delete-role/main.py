import google.auth
from google.cloud import iam_v1

def main(request):
    _, project = google.auth.default()
    role_name = request.args.get('role_name')
    client = iam_v1.IAMClient()
    role_path = f"projects/{project}/roles/{role_name}"
    client.delete_role(name=role_path)
    return f"Role {role_name} deleted successfully"