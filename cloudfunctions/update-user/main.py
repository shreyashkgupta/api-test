def main(request):
    # get user id and updated data from request body
    user_id = request.json.get('id')
    updated_data = request.json.get('data')

    # update user in the system
    # replace the following code with your own logic
    user = get_user(user_id)
    user.update(updated_data)

    # return success message
    return f"User with ID {user_id} updated successfully"