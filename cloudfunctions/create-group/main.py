import os
import requests
from google.cloud import firestore

def main(request):

    # Get credentials and initialize Firestore client
    firestore_key = os.environ.get('FIRESTORE_KEY')
    firestore_project = os.environ.get('FIRESTORE_PROJECT')
    db = firestore.Client.from_service_account_json(firestore_key, project=firestore_project)

    # Get request data
    group_name = request.json.get('group_name')

    # Create new group document in Firestore
    group_ref = db.collection('groups').document()
    group_ref.set({
        'name': group_name,
        'members': []
    })

    # Return success response
    return requests.Response(status_code=200, data='Group created successfully')