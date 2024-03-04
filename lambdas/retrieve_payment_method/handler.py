import stripe

# Set stripe api key
stripe.api_key = "sk_test_XXXXXXXXXXXXXXXXXXXXXX"

# Retrieve payment method
payment_method = stripe.PaymentMethod.retrieve(
  "pm_XXXXXXXXXXXXXXXXXXXXXX"
)