def main(request):
    from google.cloud import datastore

    # Instantiates a client
    client = datastore.Client()

    # The kind for the new entity
    kind = 'Role'

    # The Cloud Datastore key for the new entity
    task_key = client.key(kind)

    # Prepares the new entity
    task = datastore.Entity(key=task_key)
    task['name'] = 'New Role'
    task['description'] = 'A new role in the role dataset'

    # Saves the entity
    client.put(task)

    return 'New role created: {}'.format(task.key)