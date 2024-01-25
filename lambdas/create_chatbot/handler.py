import boto3

client = boto3.client('lambda')

response = client.create_function(
    FunctionName='chatbot',
    Runtime='python3.8',
    Role='arn:aws:iam::123456789012:role/lambda-role',
    Handler='chatbot.lambda_handler',
    Code={
        'ZipFile': b'PK\x03\x04\x14\x00\x08\x08\x08\x00\x00\xdd}\xecJ\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1c\x00\x00\x00chatbot.pyimport boto3\n\ndef lambda_handler(event, context):\n    client = boto3.client(\'lex-runtime\')\n    response = client.post_text(\n        botName=\'myBot\',\n        botAlias=\'myBotAlias\',\n        userId=\'user\',\n        inputText=\'Hello\')\n    return response\n\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00PK\x01\x02\x14\x03\x14\x00\x08\x08\x08\x00\x00\xdd}\xecJ\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1c\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00chatbot.pyPK\x05\x06\x00\x00\x00\x00\x01\x00\x01\x005\x00\x00\x00\xd6\x00\x00\x00\x00\x