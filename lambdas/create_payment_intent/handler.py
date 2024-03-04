import stripe

# set up Stripe API key
stripe.api_key = "sk_test_your_api_key_here"

def create_payment_intent(amount):
    # create payment intent
    intent = stripe.PaymentIntent.create(
        amount=amount,
        currency="usd",
        # add metadata if needed
        metadata={"integration_check": "accept_a_payment"}
    )
    return intent.id