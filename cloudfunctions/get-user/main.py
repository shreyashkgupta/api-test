import requests
import os

def main(request):
    user_id = request.args.get('user_id')
    api_key = os.environ.get('API_KEY')
    url = f'https://api.example.com/user/{user_id}'
    headers = {'Authorization': f'Bearer {api_key}'}
    response = requests.get(url, headers=headers)
    return response.json()