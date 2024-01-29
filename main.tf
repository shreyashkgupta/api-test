
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}





resource "aws_api_gateway_rest_api" "api_gateway_Dev_logging" {
  name        = "Dev-logging"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_Dev_logging" {
  deployment_id = aws_api_gateway_deployment.api_gateway_Dev_logging.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_Dev_logging.id
  stage_name    = "Dev"
}



resource "aws_iam_role" "lambda_role_Dev_logging" {
  name = "lambda-role-Dev-logging"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "labmda_policy_Dev_logging" {
  name        = "lambda-policy-Dev-logging"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchGetItem",
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:BatchWriteItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem"
      ],
      "Resource": "arn:aws:dynamodb:eu-west-1:123456789012:table/*"
    },
      {
        "Effect" : "Allow",
        "Action" : ["lambda:InvokeFunction"],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_Dev_logging" {
  policy_arn = aws_iam_policy.labmda_policy_Dev_logging.arn
  role = aws_iam_role.lambda_role_Dev_logging.name
}


resource "aws_dynamodb_table" "logging-Dev-chatbot_info" {
  name           = "logging-Dev-chatbot_info"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chatbot_infoId"

  attribute {
    name = "chatbot_infoId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "logging-Dev-chatbot_info"
    Environment = "Dev"
  }
}



resource "aws_dynamodb_table" "logging-Dev-chatbot_messages" {
  name           = "logging-Dev-chatbot_messages"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chatbot_messagesId"

  attribute {
    name = "chatbot_messagesId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "logging-Dev-chatbot_messages"
    Environment = "Dev"
  }
}


data "archive_file" "zip_the_python_code_Dev_create_chatbot" {
type        = "zip"
source_dir  = "lambdas/create_chatbot"
output_path = "lambdas/create_chatbot.zip"
}

resource "aws_lambda_function" "lambda_Dev_create_chatbot" {
filename                       = "lambdas/create_chatbot.zip"
function_name                  = "logging-Dev-create_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_create_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_logging.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_logging]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_create_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_create_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_logging_create_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.root_resource_id}"
  path_part   = "create_chatbot"
}

resource "aws_api_gateway_method" "proxy_Dev_logging_create_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_logging_create_chatbot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_logging_create_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_logging.id
  resource_id = aws_api_gateway_method.proxy_Dev_logging_create_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_logging_create_chatbot.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_create_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_get_chatbot" {
type        = "zip"
source_dir  = "lambdas/get_chatbot"
output_path = "lambdas/get_chatbot.zip"
}

resource "aws_lambda_function" "lambda_Dev_get_chatbot" {
filename                       = "lambdas/get_chatbot.zip"
function_name                  = "logging-Dev-get_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_get_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_logging.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_logging]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_get_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_get_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_logging_get_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.root_resource_id}"
  path_part   = "get_chatbot"
}

resource "aws_api_gateway_method" "proxy_Dev_logging_get_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_logging_get_chatbot.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_logging_get_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_logging.id
  resource_id = aws_api_gateway_method.proxy_Dev_logging_get_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_logging_get_chatbot.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_get_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_update_chatbot" {
type        = "zip"
source_dir  = "lambdas/update_chatbot"
output_path = "lambdas/update_chatbot.zip"
}

resource "aws_lambda_function" "lambda_Dev_update_chatbot" {
filename                       = "lambdas/update_chatbot.zip"
function_name                  = "logging-Dev-update_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_update_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_logging.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_logging]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_update_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_update_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_logging_update_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.root_resource_id}"
  path_part   = "update_chatbot"
}

resource "aws_api_gateway_method" "proxy_Dev_logging_update_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_logging_update_chatbot.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_logging_update_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_logging.id
  resource_id = aws_api_gateway_method.proxy_Dev_logging_update_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_logging_update_chatbot.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_update_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_delete_chatbot" {
type        = "zip"
source_dir  = "lambdas/delete_chatbot"
output_path = "lambdas/delete_chatbot.zip"
}

resource "aws_lambda_function" "lambda_Dev_delete_chatbot" {
filename                       = "lambdas/delete_chatbot.zip"
function_name                  = "logging-Dev-delete_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_delete_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_logging.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_logging]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_delete_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_delete_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_logging_delete_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.root_resource_id}"
  path_part   = "delete_chatbot"
}

resource "aws_api_gateway_method" "proxy_Dev_logging_delete_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_logging_delete_chatbot.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_logging_delete_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_logging.id
  resource_id = aws_api_gateway_method.proxy_Dev_logging_delete_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_logging_delete_chatbot.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_delete_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_get_chatbot_messages" {
type        = "zip"
source_dir  = "lambdas/get_chatbot_messages"
output_path = "lambdas/get_chatbot_messages.zip"
}

resource "aws_lambda_function" "lambda_Dev_get_chatbot_messages" {
filename                       = "lambdas/get_chatbot_messages.zip"
function_name                  = "logging-Dev-get_chatbot_messages"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_get_chatbot_messages.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_logging.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_logging]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_get_chatbot_messages" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_get_chatbot_messages.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_logging_get_chatbot_messages" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.root_resource_id}"
  path_part   = "get_chatbot_messages"
}

resource "aws_api_gateway_method" "proxy_Dev_logging_get_chatbot_messages" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_logging_get_chatbot_messages.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_logging_get_chatbot_messages" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_logging.id
  resource_id = aws_api_gateway_method.proxy_Dev_logging_get_chatbot_messages.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_logging_get_chatbot_messages.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_get_chatbot_messages.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_send_message_to_chatbot" {
type        = "zip"
source_dir  = "lambdas/send_message_to_chatbot"
output_path = "lambdas/send_message_to_chatbot.zip"
}

resource "aws_lambda_function" "lambda_Dev_send_message_to_chatbot" {
filename                       = "lambdas/send_message_to_chatbot.zip"
function_name                  = "logging-Dev-send_message_to_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_send_message_to_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_logging.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_logging]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_send_message_to_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_send_message_to_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_logging_send_message_to_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.root_resource_id}"
  path_part   = "send_message_to_chatbot"
}

resource "aws_api_gateway_method" "proxy_Dev_logging_send_message_to_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_logging.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_logging_send_message_to_chatbot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_logging_send_message_to_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_logging.id
  resource_id = aws_api_gateway_method.proxy_Dev_logging_send_message_to_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_logging_send_message_to_chatbot.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_send_message_to_chatbot.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_Dev_logging" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_logging.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_Dev_logging_create_chatbot.resource_id,
  aws_api_gateway_method.proxy_Dev_logging_create_chatbot.id,
  aws_api_gateway_integration.lambda_Dev_logging_create_chatbot.id,
  
  aws_api_gateway_method.proxy_Dev_logging_get_chatbot.resource_id,
  aws_api_gateway_method.proxy_Dev_logging_get_chatbot.id,
  aws_api_gateway_integration.lambda_Dev_logging_get_chatbot.id,
  
  aws_api_gateway_method.proxy_Dev_logging_update_chatbot.resource_id,
  aws_api_gateway_method.proxy_Dev_logging_update_chatbot.id,
  aws_api_gateway_integration.lambda_Dev_logging_update_chatbot.id,
  
  aws_api_gateway_method.proxy_Dev_logging_delete_chatbot.resource_id,
  aws_api_gateway_method.proxy_Dev_logging_delete_chatbot.id,
  aws_api_gateway_integration.lambda_Dev_logging_delete_chatbot.id,
  
  aws_api_gateway_method.proxy_Dev_logging_get_chatbot_messages.resource_id,
  aws_api_gateway_method.proxy_Dev_logging_get_chatbot_messages.id,
  aws_api_gateway_integration.lambda_Dev_logging_get_chatbot_messages.id,
  
  aws_api_gateway_method.proxy_Dev_logging_send_message_to_chatbot.resource_id,
  aws_api_gateway_method.proxy_Dev_logging_send_message_to_chatbot.id,
  aws_api_gateway_integration.lambda_Dev_logging_send_message_to_chatbot.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
