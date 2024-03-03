def main(request):
    import json
    import google.auth
    from google.cloud import bigquery

    _, PROJECT_ID = google.auth.default()
    client = bigquery.Client(project=PROJECT_ID)

    # Extracting data from the request
    request_json = request.get_json()
    role_id = request_json['role_id']
    role_name = request_json['role_name']

    # Updating the role information in the role dataset
    query = f"""
        UPDATE `dataset_name.role`
        SET role_name = '{role_name}'
        WHERE role_id = '{role_id}'
    """
    query_job = client.query(query)
    results = query_job.result()

    return json.dumps({'message': f'Role {role_id} updated successfully!'})