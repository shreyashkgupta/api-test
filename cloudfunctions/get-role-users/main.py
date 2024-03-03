def main(request):
    # Import the required libraries
    from google.cloud import bigquery
    from google.cloud import storage

    # Set up the GCP project, bucket, and dataset information
    project_id = 'your-project-id'
    bucket_name = 'your-bucket-name'
    dataset_id = 'your-dataset-id'
    table_id = 'user_role'

    # Parse the role name from the request parameter
    role_name = request.args.get('role_name')

    # Initialize the BigQuery client
    bigquery_client = bigquery.Client(project=project_id)

    # Set up the BigQuery query to retrieve all users associated with the given role
    query = f"""
        SELECT user_id
        FROM `{project_id}.{dataset_id}.{table_id}`
        WHERE role_name = "{role_name}"
    """

    # Execute the query and get the results
    query_job = bigquery_client.query(query)
    results = query_job.result()

    # Initialize the storage client
    storage_client = storage.Client(project=project_id)

    # Create a new bucket to store the results
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(f"{role_name}_users.txt")

    # Write the results to the bucket
    for row in results:
        blob.upload_from_string(row.user_id + '\n', mode='a')

    # Return a success message
    return f"Successfully retrieved and stored all users associated with the role {role_name} in {bucket_name}/{role_name}_users.txt"