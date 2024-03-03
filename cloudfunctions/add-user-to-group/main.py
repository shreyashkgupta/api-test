import google.auth
from google.cloud import iam

def main(request):
    credentials, project = google.auth.default()
    client = iam.IAMClient(credentials=credentials)
    group_name = request.get_json().get('group_name')
    member_email = request.get_json().get('member_email')
    group_path = client.group_path(project, group_name)
    member = {'user': f'users/{member_email}'}
    response = client.modify_membership(group_path, member, 'ADD')
    return f'Successfully added {member_email} to {group_name}'