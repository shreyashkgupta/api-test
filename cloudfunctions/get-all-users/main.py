def main(request):
    # Import necessary modules
    from google.cloud import firestore
    import json
    
    # Initialize Firestore client
    db = firestore.Client()
    
    # Get all users from the users collection
    users_ref = db.collection('users')
    users = [user.to_dict() for user in users_ref.stream()]
    
    # Return the users as JSON response
    return json.dumps(users)