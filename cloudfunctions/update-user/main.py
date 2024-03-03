import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

def main(request):

    # Initialize Firebase Admin SDK
    cred = credentials.Certificate('path/to/credentials.json')
    firebase_admin.initialize_app(cred)

    # Get user ID and updated details from request
    user_id = request.args.get('user_id')
    new_details = request.get_json()

    # Update user details in Firestore
    db = firestore.client()
    user_ref = db.collection('users').document(user_id)
    user_ref.update(new_details)

    return 'User details updated successfully'