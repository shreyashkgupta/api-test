import stripe

stripe.api_key = "your_secret_key"

def retrieve_customer(customer_id):
    try:
        customer = stripe.Customer.retrieve(customer_id)
        return customer
    except stripe.error.StripeError as e:
        print("Error: {}".format(e))