def main(request):
    import firebase_admin
    from firebase_admin import credentials, firestore
    import json

    # Initialize Firebase Admin SDK
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {
        'projectId': 'your-project-id',
    })

    # Get Firestore client
    db = firestore.client()

    # Get request data
    user_id = request.args.get('user_id')
    data = request.get_json()

    # Update user details in Firestore
    user_ref = db.collection('users').document(user_id)
    user_ref.update(data)

    # Return success response
    response = {'message': 'User details updated successfully'}
    return json.dumps(response)