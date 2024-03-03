import requests
import os

def main(request):
    API_KEY = os.environ.get('API_KEY')
    headers = {
        'Authorization': f'Bearer {API_KEY}',
        'Content-Type': 'application/json'
    }
    payload = {
        'name': request.get('name'),
        'email': request.get('email'),
        'password': request.get('password')
    }
    response = requests.post('https://api.example.com/users', headers=headers, json=payload)
    return response.json()