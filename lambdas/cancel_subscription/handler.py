import stripe

# Set the API key
stripe.api_key = "YOUR_API_KEY"

# Define the function to cancel a subscription
def cancel_subscription(subscription_id):
    try:
        subscription = stripe.Subscription.retrieve(subscription_id)
        subscription.delete()
        return "Subscription cancelled successfully"
    except stripe.error.StripeError as e:
        return f"Error cancelling subscription: {e}"