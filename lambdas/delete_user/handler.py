require 'aws-sdk'

def delete_user(user_id)
  client = Aws::Lambda::Client.new(region: 'us-east-1')

  resp = client.invoke({
    function_name: 'delete-user-lambda',
    invocation_type: 'RequestResponse',
    payload: { user_id: user_id }.to_json
  })

  if resp.status_code == 200
    puts "User with id #{user_id} has been deleted"
  else
    puts "Failed to delete user with id #{user_id}. Error code: #{resp.status_code}"
  end
end