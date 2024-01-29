

variable "region" {
  type = string
  description = "AWS region to deploy in"
  default = "us-west-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}



resource "aws_api_gateway_rest_api" "api_gateway_dev_Testing_2" {
  name        = "dev-Testing_2"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_Testing_2" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_Testing_2.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_Testing_2" {
  name = "lambda-role-dev-Testing_2"
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

resource "aws_iam_policy" "labmda_policy_dev_Testing_2" {
  name        = "lambda-policy-dev-Testing_2"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_Testing_2" {
  policy_arn = aws_iam_policy.labmda_policy_dev_Testing_2.arn
  role = aws_iam_role.lambda_role_dev_Testing_2.name
}


resource "aws_dynamodb_table" "Testing_2-dev-chatbot_info" {
  name           = "Testing_2-dev-chatbot_info"
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
    Name        = "Testing_2-dev-chatbot_info"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "Testing_2-dev-chat_history" {
  name           = "Testing_2-dev-chat_history"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chat_historyId"

  attribute {
    name = "chat_historyId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "Testing_2-dev-chat_history"
    Environment = "dev"
  }
}


data "archive_file" "zip_the_python_code_dev_create_chatbot" {
type        = "zip"
source_dir  = "lambdas/create_chatbot"
output_path = "lambdas/create_chatbot.zip"
}

resource "aws_lambda_function" "lambda_dev_create_chatbot" {
filename                       = "lambdas/create_chatbot.zip"
function_name                  = "Testing_2-dev-create_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Testing_2_create_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.root_resource_id}"
  path_part   = "create_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_Testing_2_create_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Testing_2_create_chatbot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Testing_2_create_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_Testing_2_create_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Testing_2_create_chatbot.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_chatbots" {
type        = "zip"
source_dir  = "lambdas/get_chatbots"
output_path = "lambdas/get_chatbots.zip"
}

resource "aws_lambda_function" "lambda_dev_get_chatbots" {
filename                       = "lambdas/get_chatbots.zip"
function_name                  = "Testing_2-dev-get_chatbots"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_chatbots.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_chatbots" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_chatbots.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Testing_2_get_chatbots" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.root_resource_id}"
  path_part   = "get_chatbots"
}

resource "aws_api_gateway_method" "proxy_dev_Testing_2_get_chatbots" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Testing_2_get_chatbots.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Testing_2_get_chatbots" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_Testing_2_get_chatbots.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Testing_2_get_chatbots.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_chatbots.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_chatbot" {
type        = "zip"
source_dir  = "lambdas/update_chatbot"
output_path = "lambdas/update_chatbot.zip"
}

resource "aws_lambda_function" "lambda_dev_update_chatbot" {
filename                       = "lambdas/update_chatbot.zip"
function_name                  = "Testing_2-dev-update_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Testing_2_update_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.root_resource_id}"
  path_part   = "update_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_Testing_2_update_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Testing_2_update_chatbot.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Testing_2_update_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_Testing_2_update_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Testing_2_update_chatbot.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_delete_chatbot" {
type        = "zip"
source_dir  = "lambdas/delete_chatbot"
output_path = "lambdas/delete_chatbot.zip"
}

resource "aws_lambda_function" "lambda_dev_delete_chatbot" {
filename                       = "lambdas/delete_chatbot.zip"
function_name                  = "Testing_2-dev-delete_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Testing_2_delete_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.root_resource_id}"
  path_part   = "delete_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_Testing_2_delete_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Testing_2_delete_chatbot.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Testing_2_delete_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_Testing_2_delete_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Testing_2_delete_chatbot.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_chat_history" {
type        = "zip"
source_dir  = "lambdas/get_chat_history"
output_path = "lambdas/get_chat_history.zip"
}

resource "aws_lambda_function" "lambda_dev_get_chat_history" {
filename                       = "lambdas/get_chat_history.zip"
function_name                  = "Testing_2-dev-get_chat_history"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_chat_history.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_chat_history" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_chat_history.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Testing_2_get_chat_history" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.root_resource_id}"
  path_part   = "get_chat_history"
}

resource "aws_api_gateway_method" "proxy_dev_Testing_2_get_chat_history" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Testing_2_get_chat_history.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Testing_2_get_chat_history" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_Testing_2_get_chat_history.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Testing_2_get_chat_history.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_chat_history.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_send_message" {
type        = "zip"
source_dir  = "lambdas/send_message"
output_path = "lambdas/send_message.zip"
}

resource "aws_lambda_function" "lambda_dev_send_message" {
filename                       = "lambdas/send_message.zip"
function_name                  = "Testing_2-dev-send_message"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_send_message.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_send_message" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_send_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Testing_2_send_message" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.root_resource_id}"
  path_part   = "send_message"
}

resource "aws_api_gateway_method" "proxy_dev_Testing_2_send_message" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Testing_2_send_message.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Testing_2_send_message" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_Testing_2_send_message.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Testing_2_send_message.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_send_message.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_search_chat_history" {
type        = "zip"
source_dir  = "lambdas/search_chat_history"
output_path = "lambdas/search_chat_history.zip"
}

resource "aws_lambda_function" "lambda_dev_search_chat_history" {
filename                       = "lambdas/search_chat_history.zip"
function_name                  = "Testing_2-dev-search_chat_history"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_search_chat_history.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_search_chat_history" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_search_chat_history.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Testing_2_search_chat_history" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.root_resource_id}"
  path_part   = "search_chat_history"
}

resource "aws_api_gateway_method" "proxy_dev_Testing_2_search_chat_history" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Testing_2_search_chat_history.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Testing_2_search_chat_history" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_Testing_2_search_chat_history.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Testing_2_search_chat_history.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_search_chat_history.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_Testing_2" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Testing_2.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_Testing_2_create_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_Testing_2_create_chatbot.id,
  aws_api_gateway_integration.lambda_dev_Testing_2_create_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_Testing_2_get_chatbots.resource_id,
  aws_api_gateway_method.proxy_dev_Testing_2_get_chatbots.id,
  aws_api_gateway_integration.lambda_dev_Testing_2_get_chatbots.id,
  
  aws_api_gateway_method.proxy_dev_Testing_2_update_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_Testing_2_update_chatbot.id,
  aws_api_gateway_integration.lambda_dev_Testing_2_update_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_Testing_2_delete_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_Testing_2_delete_chatbot.id,
  aws_api_gateway_integration.lambda_dev_Testing_2_delete_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_Testing_2_get_chat_history.resource_id,
  aws_api_gateway_method.proxy_dev_Testing_2_get_chat_history.id,
  aws_api_gateway_integration.lambda_dev_Testing_2_get_chat_history.id,
  
  aws_api_gateway_method.proxy_dev_Testing_2_send_message.resource_id,
  aws_api_gateway_method.proxy_dev_Testing_2_send_message.id,
  aws_api_gateway_integration.lambda_dev_Testing_2_send_message.id,
  
  aws_api_gateway_method.proxy_dev_Testing_2_search_chat_history.resource_id,
  aws_api_gateway_method.proxy_dev_Testing_2_search_chat_history.id,
  aws_api_gateway_integration.lambda_dev_Testing_2_search_chat_history.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
