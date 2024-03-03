import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth

cred = credentials.Certificate('path/to/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

def main(request):
    user_id = request.args.get('user_id')
    try:
        auth.delete_user(user_id)
        return f"User with ID {user_id} has been deleted successfully."
    except auth.AuthError as e:
        return f"Error deleting user: {e}"