import stripe

stripe.api_key = "your_api_key"

def create_customer(name, email, payment_method=None):
    try:
        customer = stripe.Customer.create(
            name=name,
            email=email,
            payment_method=payment_method
        )
        return customer
    except stripe.error.CardError as e:
        # Since it's a decline, stripe.error.CardError will be caught
        print("Status is: %s" % e.http_status)
        print("Type is: %s" % e.error.type)
        print("Code is: %s" % e.error.code)
        # param is '' in this case
        print("Param is: %s" % e.error.param)
        print("Message is: %s" % e.error.message)
    except stripe.error.StripeError as e:
        # Display a very generic error to the user, and maybe send
        # yourself an email
        print("Something went wrong. Please try again later.")