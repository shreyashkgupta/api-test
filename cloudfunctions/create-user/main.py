def main(request):
    from google.cloud import datastore
    
    client = datastore.Client()
    kind = 'User'
    task_key = client.key(kind)
    
    task = datastore.Entity(key=task_key)
    task['name'] = 'New User'
    task['email'] = 'newuser@example.com'
    
    client.put(task)

    return 'New user created successfully.'