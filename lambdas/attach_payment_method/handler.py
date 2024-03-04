import stripe

stripe.api_key = "your_secret_key"

def attach_payment_method(customer_id, payment_method_id):
    try:
        payment_method = stripe.PaymentMethod.attach(
            payment_method_id,
            customer=customer_id,
        )
        return payment_method
    except stripe.error.StripeError as e:
        return e