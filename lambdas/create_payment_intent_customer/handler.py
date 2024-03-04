import stripe

stripe.api_key = "sk_test_..."

def create_payment_intent(customer_id, amount, currency):
    intent = stripe.PaymentIntent.create(
        amount=amount,
        currency=currency,
        customer=customer_id
    )
    return intent.id