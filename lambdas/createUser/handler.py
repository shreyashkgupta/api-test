import os


def lambda_handler(event, context):
    message = "Hello from `{}` !".format(os.environ["AWS_LAMBDA_FUNCTION_NAME"])
    return {"message": message}

