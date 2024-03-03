import google.auth
from google.auth import credentials
from google.cloud import resource_manager
from google.oauth2 import service_account
from googleapiclient.discovery import build

def main(request):
    credentials, project_id = google.auth.default(
        scopes=['https://www.googleapis.com/auth/cloud-platform'])
    crm_service = build('cloudresourcemanager', 'v1', credentials=credentials)
    groups = crm_service.projects().getAncestry(
        resourceId=request.json['group_id']).execute()
    for group in groups['ancestor']:
        if group['resourceId'].startswith('group_id'):
            group_email = group['resourceId'][len('group_id')+1:]
            break
    else:
        return 'Group not found', 404
    
    credentials = service_account.Credentials.from_service_account_info(request.json['secrets'])
    admin_service = build('admin', 'directory_v1', credentials=credentials)
    try:
        admin_service.members().delete(groupKey=group_email, memberKey=request.json['user_email']).execute()
        return f"{request.json['user_email']} was removed from {group_email}"
    except Exception as e:
        return f"An error occurred: {e}", 500