def main(request):
    # Import necessary libraries
    from google.cloud import bigquery

    # Set up BigQuery client
    client = bigquery.Client()

    # Set up query to retrieve user information
    query = """
        SELECT *
        FROM `project.dataset.user`
    """

    # Execute the query and retrieve results
    results = client.query(query)

    # Convert results to list of dictionaries
    users = [dict(row) for row in results]

    return users