require 'aws-sdk-lambda'

def update_user(user_id, user_data)
  client = Aws::Lambda::Client.new(
    region: 'us-east-1',
    access_key_id: 'ACCESS_KEY_ID',
    secret_access_key: 'SECRET_ACCESS_KEY'
  )
  
  resp = client.invoke({
    function_name: 'update_user_function',
    payload: { user_id: user_id, user_data: user_data }.to_json
  })
  
  if resp.status_code == 200
    return resp.payload
  else
    raise "Error updating user: #{resp.function_error}"
  end
end