import stripe

# Set your API key
stripe.api_key = "your_stripe_secret_key"

# Define function to cancel payment intent
def cancel_payment_intent(payment_intent_id):
    try:
        payment_intent = stripe.PaymentIntent.retrieve(payment_intent_id)
        if payment_intent.status == "requires_payment_method" or payment_intent.status == "requires_confirmation":
            payment_intent.cancel()
            return f"Payment intent {payment_intent_id} has been cancelled."
        else:
            return f"Payment intent {payment_intent_id} cannot be cancelled as it is already in {payment_intent.status} status."
    except stripe.error.StripeError as e:
        return f"Error occured while cancelling payment intent {payment_intent_id}: {e}"