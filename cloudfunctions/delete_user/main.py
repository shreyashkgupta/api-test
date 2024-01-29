def delete_user(request):
    user_id = request.args.get('user_id')
    # code to delete user information from the user management system
    return f"User with ID {user_id} has been deleted successfully"