import os
from google.cloud import firestore, error_reporting

def main(request):
    # Set up error reporting
    client = error_reporting.Client()
    try:
        # Get credentials and initialize Firestore client
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "path/to/credentials.json"
        db = firestore.Client()

        # Get role by ID or name from Firestore
        role_ref = db.collection(u'roles').document(request.args.get('id'))
        role = role_ref.get()
        if not role.exists:
            role_ref = db.collection(u'roles').where(u'name', u'==', request.args.get('name')).get()
            if not role_ref:
                return f"No role found with ID {request.args.get('id')} or name {request.args.get('name')}"
            role = role_ref[0]

        # Return role data
        return role.to_dict()

    except Exception as e:
        # Report any errors to Stackdriver Error Reporting
        client.report_exception()
        return f"An error occurred: {e}"