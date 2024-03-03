def main(request):
    user_id = request.args.get('user_id')
    # code to retrieve user from the system
    return f"User with id {user_id} retrieved successfully"