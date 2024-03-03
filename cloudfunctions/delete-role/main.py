def main(request):
    from google.cloud import datastore

    client = datastore.Client()

    role_key = client.key('Role', request.json['id'])
    client.delete(role_key)

    return f"Role {request.json['id']} deleted successfully."