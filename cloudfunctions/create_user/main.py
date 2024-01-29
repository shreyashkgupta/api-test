def create_user(request):
    # Parse request data
    user_data = request.get_json()
    
    # Validate request data
    if not user_data:
        return 'Request body is empty', 400
    if 'name' not in user_data or not user_data['name']:
        return 'User name is required', 400
    if 'email' not in user_data or not user_data['email']:
        return 'User email is required', 400
    
    # Save user data to database
    # Replace this with your actual implementation
    user_id = save_user_to_database(user_data)
    
    # Return success response with user ID
    return {'user_id': user_id}, 201