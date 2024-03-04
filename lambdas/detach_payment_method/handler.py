import stripe

# Set the API key
stripe.api_key = "sk_test_XXXXXX"

# Define the function to detach a payment method from a customer
def detach_payment_method(customer_id, payment_method_id):
    try:
        stripe.PaymentMethod.detach(
            payment_method_id,
            customer=customer_id
        )
        print("Payment method detached successfully.")
    except stripe.error.StripeError as e:
        print("Error: ", e)