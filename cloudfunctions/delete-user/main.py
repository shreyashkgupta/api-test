def main(request):
    user_id = request.args.get('user_id')
    # Delete user with user_id from user management system
    return f"User with ID {user_id} has been deleted."