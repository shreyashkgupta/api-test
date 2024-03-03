def main(request):
    from google.cloud import bigquery

    request_json = request.get_json()
    if request_json and 'user_id' in request_json and 'role_id' in request_json:
        user_id = request_json['user_id']
        role_id = request_json['role_id']

        client = bigquery.Client()
        query = """
            INSERT INTO `your-project-id.your-dataset.user_role`
            (user_id, role_id)
            VALUES ('{}', '{}')
        """.format(user_id, role_id)

        job_config = bigquery.QueryJobConfig()
        query_job = client.query(query, job_config=job_config)
        return "User {} added to role {} in user_role dataset.".format(user_id, role_id)

    else:
        return "Invalid request. Please provide user_id and role_id in the request body."