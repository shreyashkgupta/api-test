import os
from google.cloud import firestore

def main(request):
    user_id = request.args.get('user_id')
    if not user_id:
        return 'User ID is required', 400

    db = firestore.Client()

    user_ref = db.collection('users').document(user_id)
    if not user_ref.get().exists:
        return f'User with ID {user_id} does not exist', 404

    user_ref.delete()

    return f'User with ID {user_id} has been deleted', 200