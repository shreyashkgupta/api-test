require 'aws-sdk-lambda'

def get_user_handler(event:, context:)
  # Add code to retrieve user from user management system
end

creds = Aws::Credentials.new('ACCESS_KEY_ID', 'SECRET_ACCESS_KEY')
client = Aws::Lambda::Client.new(region: 'us-west-2', credentials: creds)

resp = client.create_function({
  function_name: 'get_user',
  runtime: 'ruby2.7',
  role: 'arn:aws:iam::123456789012:role/lambda-role',
  handler: 'get_user_handler',
  code: {
    zip_file: File.open('get_user_function.zip', 'rb').read
  },
  description: 'Retrieves a user from the user management system',
  timeout: 30,
  memory_size: 128
})

puts resp.function_arn