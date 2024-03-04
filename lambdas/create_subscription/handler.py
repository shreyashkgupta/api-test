import stripe

stripe.api_key = "your_stripe_api_key"

def create_subscription(customer_id, plan_id):
    try:
        subscription = stripe.Subscription.create(
            customer=customer_id,
            items=[{
                "plan": plan_id,
            }]
        )
        return subscription
    except stripe.error.StripeError as e:
        print(e)