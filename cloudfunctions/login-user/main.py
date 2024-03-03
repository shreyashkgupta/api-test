def main(request):
    # Import required libraries
    import jwt
    from google.oauth2 import id_token
    from google.auth.transport import requests

    # Get the token from the request
    token = request.args.get('token')

    # Verify and decode the token
    try:
        idinfo = id_token.verify_oauth2_token(token, requests.Request())
        user_id = idinfo['sub']
    except Exception as e:
        return f"Authentication failed: {str(e)}"

    # Generate the JWT token
    jwt_token = jwt.encode({'user_id': user_id}, 'secret_key', algorithm='HS256')

    # Return the JWT token
    return jwt_token