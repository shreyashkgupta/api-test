import stripe

# Set the stripe API key
stripe.api_key = "YOUR_STRIPE_SECRET_KEY"

# Create a new payment intent with a payment method
intent = stripe.PaymentIntent.create(
    amount=1000, # Amount in cents
    currency="usd",
    payment_method="pm_card_visa", # Payment method ID
    description="New Payment Intent"
)

# Print the payment intent ID
print(intent.id)