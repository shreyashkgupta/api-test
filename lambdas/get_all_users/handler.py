require 'aws-sdk-lambda'
require 'aws-sdk-secretsmanager'

# Retrieve credentials from AWS Secrets Manager
secrets_manager = Aws::SecretsManager::Client.new(region: 'us-east-1')
secret_value = secrets_manager.get_secret_value(secret_id: 'my_secret_id')
secrets = JSON.parse(secret_value.secret_string)

# Define the lambda function
lambda_client = Aws::Lambda::Client.new(region: 'us-east-1', access_key_id: secrets['access_key_id'], secret_access_key: secrets['secret_access_key'])
function_name = 'get_all_users'
handler = 'users.get_all'
runtime = 'ruby2.7'
role = 'arn:aws:iam::1234567890:role/lambda-execution-role'

lambda_client.create_function({
  function_name: function_name,
  handler: handler,
  runtime: runtime,
  role: role,
  code: {
    zip_file: File.open('./users.zip', 'rb').read
  },
  description: 'Retrieves all users from the user management system.'
})