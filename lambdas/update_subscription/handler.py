import stripe

def lambda_handler(event, context):
    
    # Set your API key
    stripe.api_key = 'sk_test_XXXXXXXXXXXXXXXXXXXXXXXX'

    # Retrieve the subscription id from the event
    subscription_id = event['subscription_id']

    # Retrieve the new subscription data from the event
    new_subscription_data = event['new_subscription_data']

    # Update the subscription in Stripe
    updated_subscription = stripe.Subscription.modify(
        subscription_id,
        **new_subscription_data
    )

    return updated_subscription