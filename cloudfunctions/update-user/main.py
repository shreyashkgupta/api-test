import os
from google.cloud import firestore

def main(request):
    # Authenticate with firestore
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/path/to/credentials.json"
    db = firestore.Client()

    # Get user data from request
    user_id = request.args.get('user_id')
    user_data = request.get_json()

    # Update user details in firestore
    user_ref = db.collection('users').document(user_id)
    user_ref.update(user_data)

    return 'User details updated successfully'