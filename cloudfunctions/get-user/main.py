import os
from google.oauth2 import service_account
from google.cloud import firestore
from flask import jsonify

def main(request):
    # authenticate using the service account key file
    keyfile_dict = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    credentials = service_account.Credentials.from_service_account_info(keyfile_dict)

    # initialize firestore client
    db = firestore.Client(credentials=credentials)

    # retrieve user details
    user_ref = db.collection('users').document(request.args.get('user_id'))
    user = user_ref.get().to_dict()

    return jsonify(user)