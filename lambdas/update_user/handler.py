import boto3

# Initialize AWS credentials
aws_access_key_id = 'YOUR_AWS_ACCESS_KEY_ID'
aws_secret_access_key = 'YOUR_AWS_SECRET_ACCESS_KEY'
region_name = 'YOUR_AWS_REGION_NAME'

# Initialize the AWS client
client = boto3.client('lambda', aws_access_key_id=aws_access_key_id, aws_secret_access_key=aws_secret_access_key, region_name=region_name)

# Define the lambda function
def update_user(event, context):
    # Your code to update the user in the user management system goes here
    pass

# Create the lambda function
response = client.create_function(
    FunctionName='update_user',
    Runtime='python3.8',
    Role='YOUR_AWS_LAMBDA_ROLE',
    Handler='lambda_function.update_user',
    Code={
        'ZipFile': b'ZIP_FILE_CONTENTS'
    },
    Timeout=300,
    MemorySize=128
)

print(response)