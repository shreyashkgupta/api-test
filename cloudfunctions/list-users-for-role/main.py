import google.auth
from google.cloud import firestore

def main(request):
    # Get credentials
    credentials, project = google.auth.default()

    # Initialize Firestore client
    db = firestore.Client(project=project, credentials=credentials)

    # Get role from request parameter
    role = request.args.get('role')

    # Query Firestore for users with the specified role
    query = db.collection('users').where('role', '==', role)
    users = [doc.to_dict() for doc in query.stream()]

    # Return users as JSON
    return {'users': users}