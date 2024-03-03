def main(request):
    from google.cloud import bigquery
    
    client = bigquery.Client()
    dataset_id = 'user_role'
    table_id = 'user_role_table'

    request_json = request.get_json()
    user_id = request_json['user_id']
    role_id = request_json['role_id']

    table_ref = client.dataset(dataset_id).table(table_id)
    table = client.get_table(table_ref)

    query = (
        f"DELETE FROM `{table.project}.{table.dataset_id}.{table.table_id}` "
        f"WHERE user_id = '{user_id}' AND role_id = '{role_id}'"
    )

    job_config = bigquery.QueryJobConfig()
    job_config.use_legacy_sql = False

    query_job = client.query(query, job_config=job_config)

    return 'User removed from role successfully'