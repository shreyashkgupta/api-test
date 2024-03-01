def main(request):
    if request.method == 'POST':
        # Get user data from request body
        user_data = request.get_json()
        # TODO: Add code to create new user with user_data
        return 'User created successfully!'
    else:
        return 'Error: Invalid request method. Only POST requests are allowed.'