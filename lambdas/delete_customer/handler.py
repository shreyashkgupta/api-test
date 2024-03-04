import stripe

# Set the API key
stripe.api_key = "your_stripe_secret_key"

def delete_customer(customer_id):
    # Delete the customer
    try:
        deleted_customer = stripe.Customer.delete(customer_id)
        return f"Customer {customer_id} has been deleted successfully"
    except Exception as e:
        return f"Error deleting customer: {e}"