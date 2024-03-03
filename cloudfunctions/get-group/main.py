import requests
import os
import json

def main(request):
    group_id = request.args.get('group_id')
    auth_token = os.environ.get('AUTH_TOKEN')

    headers = {
        'Authorization': f'Bearer {auth_token}',
        'Content-Type': 'application/json'
    }

    response = requests.get(f'https://example.com/groups/{group_id}', headers=headers)

    if response.status_code == 200:
        group_details = response.json()
        return json.dumps(group_details)
    else:
        return f'Error: {response.status_code}'