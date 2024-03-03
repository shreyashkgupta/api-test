import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Use a service account
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

def main(request):
    user_id = request.args.get('user_id')
    if user_id:
        user_ref = db.collection('users').document(user_id)
        user_ref.delete()
        return f"User with ID {user_id} has been deleted."
    else:
        return "No user ID provided."