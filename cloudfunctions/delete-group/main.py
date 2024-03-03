import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

def main(request):
    # Use a service account
    cred = credentials.Certificate('path/to/serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

    # Get Firestore client
    db = firestore.client()

    # Get the group id from request body
    group_id = request.json['group_id']

    # Delete the group document
    db.collection('groups').document(group_id).delete()

    return f'Group {group_id} deleted successfully!'