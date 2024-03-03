import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Use a service account
cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

# Initialize Firestore DB
db = firestore.client()

def main(request):
    user_id = request.args.get('user_id')
    name = request.args.get('name')
    email = request.args.get('email')

    user_ref = db.collection('users').document(user_id)

    user_data = {}
    if name:
        user_data['name'] = name
    if email:
        user_data['email'] = email

    user_ref.update(user_data)

    return "User updated successfully!"