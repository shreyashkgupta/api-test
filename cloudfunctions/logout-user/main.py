def main(request):
    # Check if token is valid and get the user ID
    user_id = validate_token(request)
    
    # Invalidate the token
    invalidate_token(request)
    
    # Log out the user
    logout_user(user_id)
    
    # Return success message
    return 'User logged out and token invalidated successfully.'