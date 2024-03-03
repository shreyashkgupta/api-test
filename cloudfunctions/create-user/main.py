import os
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Initialize Firebase SDK
cred = credentials.Certificate(os.environ.get('FIREBASE_KEY'))
firebase_admin.initialize_app(cred)

# Create a new user
def main(request):
    request_json = request.get_json()

    # Extract user information from request
    user_id = request_json['user_id']
    name = request_json['name']
    email = request_json['email']

    # Create a Firestore client
    db = firestore.client()

    # Add new user document to users collection
    user_ref = db.collection('users').document(user_id)
    user_ref.set({
        'name': name,
        'email': email
    })

    return 'New user created successfully!'