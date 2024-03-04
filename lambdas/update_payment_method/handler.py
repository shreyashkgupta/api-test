import stripe

stripe.api_key = "YOUR_SECRET_KEY"

def update_payment_method(payment_method_id, **kwargs):
    payment_method = stripe.PaymentMethod.retrieve(payment_method_id)
    payment_method = payment_method.update(**kwargs)
    return payment_method