def main(request):
    import firebase_admin
    from firebase_admin import credentials
    from firebase_admin import firestore

    # Initialize Firestore DB
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {
        'projectId': 'your-project-id',
    })
    db = firestore.client()

    # Get user ID from request
    user_id = request.args.get('user_id')

    # Delete user document
    user_ref = db.collection('users').document(user_id)
    user_ref.delete()

    return f"User {user_id} deleted successfully."