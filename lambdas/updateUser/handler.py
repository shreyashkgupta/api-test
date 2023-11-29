import json

def lambda_handler(event, context):
    # Retrieve user details from event
    user_id = event['user_id']
    name = event['name']
    email = event['email']
    phone_number = event['phone_number']

    # Update user details in database
    # Replace with actual update logic
    update_user_details(user_id, name, email, phone_number)

    # Return success message
    return {
        'statusCode': 200,
        'body': json.dumps('User details updated successfully!')
    }