import stripe

stripe.api_key = "sk_test_1234567890" # replace with your own API key

def retrieve_payment_intent(payment_intent_id):
    payment_intent = stripe.PaymentIntent.retrieve(payment_intent_id)
    return payment_intent