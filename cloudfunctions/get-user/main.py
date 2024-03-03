import os
from google.cloud import firestore

def main(request):
    # check if request has query parameters
    if request.args:
        user_id = request.args.get('id')
        user_email = request.args.get('email')
        
        # initialize Firestore client
        cred = credentials.Certificate(os.environ.get('GOOGLE_APPLICATION_CREDENTIALS'))
        client = firestore.Client(credentials=cred, project=os.environ.get('PROJECT_ID'))
        
        # check if user exists
        if user_id:
            user_ref = client.collection('users').document(user_id)
            user = user_ref.get()
            if user.exists:
                return user.to_dict(), 200
            else:
                return 'User not found', 404
        elif user_email:
            query = client.collection('users').where('email', '==', user_email).limit(1)
            user = query.get()
            if user:
                return user[0].to_dict(), 200
            else:
                return 'User not found', 404
        else:
            return 'Invalid request', 400
    else:
        return 'Invalid request', 400