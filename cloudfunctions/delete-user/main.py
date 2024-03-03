def main(request):
    from google.cloud import firestore
    
    db = firestore.Client()
    
    user_id = request.args.get('user_id')
    
    if user_id is None:
        return 'User id is required', 400
    
    user_ref = db.collection('users').document(user_id)
    
    if not user_ref.get().exists:
        return 'User not found', 404
    
    user_ref.delete()
    
    return f'User {user_id} deleted successfully', 200