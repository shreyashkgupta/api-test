def main(request):
    import json
    import pandas as pd
    
    request_json = request.get_json()
    user_id = request_json['user_id']
    
    # Replace with your own code to retrieve user roles from user_role dataset
    user_roles = pd.read_csv('user_role.csv')
    user_roles = user_roles[user_roles['user_id']==user_id]['role'].tolist()
    
    return json.dumps(user_roles)