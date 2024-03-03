def main(request):
    from google.cloud import bigquery
    client = bigquery.Client()
    query_job = client.query("""
        SELECT *
        FROM `project.dataset.role`
    """)
    results = query_job.result()
    for row in results:
        print(row)
    return 'Role information retrieved'