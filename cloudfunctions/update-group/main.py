import os
from google.oauth2 import service_account
from google.cloud import firestore

def main(request):
    credentials = service_account.Credentials.from_service_account_file(os.environ['GOOGLE_APPLICATION_CREDENTIALS'])
    db = firestore.Client(credentials=credentials)
    
    group_id = request.args.get('group_id')
    group_name = request.args.get('group_name')
    group_description = request.args.get('group_description')
    
    group_ref = db.collection('groups').document(group_id)
    group_data = {
        'name': group_name,
        'description': group_description
    }
    group_ref.set(group_data, merge=True)
    
    return f'Group {group_id} details updated'