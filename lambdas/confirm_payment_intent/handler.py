import stripe
import os

def confirm_payment_intent(payment_intent_id):
    stripe.api_key = os.environ['STRIPE_SECRET_KEY']
    payment_intent = stripe.PaymentIntent.confirm(payment_intent_id)
    return payment_intent