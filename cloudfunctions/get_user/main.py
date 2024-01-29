def get_user_info(request):
    # Import necessary libraries
    import requests
    
    # Set the URL of the user management system API
    url = "https://user-management-system.com/api/get_user_info"
    
    # Send a GET request to the API with the user's ID as a parameter
    user_id = request.args.get("user_id")
    response = requests.get(url, params={"user_id": user_id})
    
    # Return the response as JSON
    return response.json()