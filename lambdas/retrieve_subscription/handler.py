import stripe

def lambda_handler(event, context):
    # Retrieve the subscription ID from event data
    subscription_id = event['subscription_id']
    
    # Set up Stripe API key
    stripe.api_key = 'YOUR_API_KEY_HERE'
    
    # Retrieve the subscription from Stripe
    subscription = stripe.Subscription.retrieve(subscription_id)
    
    # Return the subscription object
    return subscription.to_dict()