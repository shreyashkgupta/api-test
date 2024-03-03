def main(request):
    import firebase_admin
    from firebase_admin import credentials
    from firebase_admin import firestore

    # initialize firestore
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {
        'projectId': 'your-project-id',
    })

    # get user id from request
    user_id = request.args.get('user_id')

    # delete user from firestore
    db = firestore.client()
    db.collection('users').document(user_id).delete()

    # return success message
    return f"User {user_id} successfully deleted."