import stripe

stripe.api_key = "your_api_key"

def update_customer(customer_id, **kwargs):
    try:
        customer = stripe.Customer.retrieve(customer_id)
        for key, value in kwargs.items():
            setattr(customer, key, value)
        customer.save()
        return "Customer updated successfully!"
    except stripe.error.StripeError as e:
        return e