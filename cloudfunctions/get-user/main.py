def main(request):
    # Import necessary libraries
    from google.cloud import firestore

    # Initialize Firestore client
    db = firestore.Client()

    # Get user ID from request
    user_id = request.args.get('user_id')

    # Get user document from Firestore
    user_doc = db.collection('users').document(user_id).get()

    # Check if user exists
    if not user_doc.exists:
        return 'User does not exist'

    # Get user details
    user_data = user_doc.to_dict()

    # Return user details as JSON
    return user_data