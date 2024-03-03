def main(request):
    import json
    
    # Parse request body
    request_json = request.get_json()
    user_id = request_json['user_id']
    new_info = request_json['new_info']
    
    # Update user information in dataset
    dataset = get_user_dataset()
    dataset[user_id].update(new_info)
    save_user_dataset(dataset)
    
    return json.dumps({'success': True})