require 'aws-sdk-lambda'
require 'aws-sdk-secretsmanager'

secrets_manager = Aws::SecretsManager::Client.new(region: 'us-east-1')

secret_value = secrets_manager.get_secret_value(secret_id: 'user-management-system-credentials')

credentials = JSON.parse(secret_value.secret_string)

lambda_client = Aws::Lambda::Client.new(region: 'us-east-1', access_key_id: credentials['access_key_id'], secret_access_key: credentials['secret_access_key'])

create_user_function = <<~LAMBDA
  def lambda_handler(event:, context:)
    # add user creation logic here
  end
LAMBDA

lambda_client.create_function(
  function_name: 'create-user',
  runtime: 'ruby2.7',
  role: 'arn:aws:iam::123456789012:role/lambda-role',
  handler: 'index.lambda_handler',
  code: {
    zip_file: create_user_function
  }
)