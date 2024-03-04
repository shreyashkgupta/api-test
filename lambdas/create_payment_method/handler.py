import stripe

stripe.api_key = "sk_test_1234567890"

def create_new_payment_method():
    try:
        payment_method = stripe.PaymentMethod.create(
            type="card",
            card={
                "number": "4242424242424242",
                "exp_month": 12,
                "exp_year": 2022,
                "cvc": "314",
            },
        )
        print(payment_method)
    except stripe.error.CardError as e:
        # Error handling
        pass