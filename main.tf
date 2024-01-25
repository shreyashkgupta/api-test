

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



resource "aws_api_gateway_rest_api" "api_gateway_dev_chatbot" {
  name        = "dev-chatbot"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_chatbot" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_chatbot.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_chatbot" {
  name = "lambda-role-dev-chatbot"
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

resource "aws_iam_policy" "labmda_policy_dev_chatbot" {
  name        = "lambda-policy-dev-chatbot"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_chatbot" {
  policy_arn = aws_iam_policy.labmda_policy_dev_chatbot.arn
  role = aws_iam_role.lambda_role_dev_chatbot.name
}


resource "aws_dynamodb_table" "chatbot-dev-chatbots" {
  name           = "chatbot-dev-chatbots"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chatbotsId"

  attribute {
    name = "chatbotsId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "chatbot-dev-chatbots"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "chatbot-dev-users" {
  name           = "chatbot-dev-users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "usersId"

  attribute {
    name = "usersId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "chatbot-dev-users"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "chatbot-dev-chat_history" {
  name           = "chatbot-dev-chat_history"
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
    Name        = "chatbot-dev-chat_history"
    Environment = "dev"
  }
}


data "archive_file" "zip_the_python_code_dev_create_user" {
type        = "zip"
source_dir  = "lambdas/create_user"
output_path = "lambdas/create_user.zip"
}

resource "aws_lambda_function" "lambda_dev_create_user" {
filename                       = "lambdas/create_user.zip"
function_name                  = "chatbot-dev-create_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_create_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "create_user"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_create_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_create_user.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_create_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_create_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_create_user.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_user" {
type        = "zip"
source_dir  = "lambdas/get_user"
output_path = "lambdas/get_user.zip"
}

resource "aws_lambda_function" "lambda_dev_get_user" {
filename                       = "lambdas/get_user.zip"
function_name                  = "chatbot-dev-get_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_get_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "get_user"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_get_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_get_user.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_get_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_get_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_get_user.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_user" {
type        = "zip"
source_dir  = "lambdas/update_user"
output_path = "lambdas/update_user.zip"
}

resource "aws_lambda_function" "lambda_dev_update_user" {
filename                       = "lambdas/update_user.zip"
function_name                  = "chatbot-dev-update_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_update_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "update_user"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_update_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_update_user.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_update_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_update_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_update_user.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_delete_user" {
type        = "zip"
source_dir  = "lambdas/delete_user"
output_path = "lambdas/delete_user.zip"
}

resource "aws_lambda_function" "lambda_dev_delete_user" {
filename                       = "lambdas/delete_user.zip"
function_name                  = "chatbot-dev-delete_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_delete_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "delete_user"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_delete_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_delete_user.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_delete_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_delete_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_delete_user.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_chatbot" {
type        = "zip"
source_dir  = "lambdas/create_chatbot"
output_path = "lambdas/create_chatbot.zip"
}

resource "aws_lambda_function" "lambda_dev_create_chatbot" {
filename                       = "lambdas/create_chatbot.zip"
function_name                  = "chatbot-dev-create_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_create_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "create_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_create_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_create_chatbot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_create_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_create_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_create_chatbot.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_chatbot" {
type        = "zip"
source_dir  = "lambdas/get_chatbot"
output_path = "lambdas/get_chatbot.zip"
}

resource "aws_lambda_function" "lambda_dev_get_chatbot" {
filename                       = "lambdas/get_chatbot.zip"
function_name                  = "chatbot-dev-get_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_get_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "get_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_get_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_get_chatbot.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_get_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_get_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_get_chatbot.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_chatbot" {
type        = "zip"
source_dir  = "lambdas/update_chatbot"
output_path = "lambdas/update_chatbot.zip"
}

resource "aws_lambda_function" "lambda_dev_update_chatbot" {
filename                       = "lambdas/update_chatbot.zip"
function_name                  = "chatbot-dev-update_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_update_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "update_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_update_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_update_chatbot.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_update_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_update_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_update_chatbot.http_method

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
function_name                  = "chatbot-dev-delete_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_delete_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "delete_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_delete_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_delete_chatbot.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_delete_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_delete_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_delete_chatbot.http_method

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
function_name                  = "chatbot-dev-get_chat_history"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_chat_history.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_chat_history" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_chat_history.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_get_chat_history" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "get_chat_history"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_get_chat_history" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_get_chat_history.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_get_chat_history" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_get_chat_history.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_get_chat_history.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_chat_history.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_chat_history" {
type        = "zip"
source_dir  = "lambdas/create_chat_history"
output_path = "lambdas/create_chat_history.zip"
}

resource "aws_lambda_function" "lambda_dev_create_chat_history" {
filename                       = "lambdas/create_chat_history.zip"
function_name                  = "chatbot-dev-create_chat_history"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_chat_history.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_chatbot.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_chatbot]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_chat_history" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_chat_history.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_chatbot_create_chat_history" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.root_resource_id}"
  path_part   = "create_chat_history"
}

resource "aws_api_gateway_method" "proxy_dev_chatbot_create_chat_history" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_chatbot.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_chatbot_create_chat_history.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_chatbot_create_chat_history" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id
  resource_id = aws_api_gateway_method.proxy_dev_chatbot_create_chat_history.resource_id
  http_method = aws_api_gateway_method.proxy_dev_chatbot_create_chat_history.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_chat_history.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_chatbot.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_chatbot_create_user.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_create_user.id,
  aws_api_gateway_integration.lambda_dev_chatbot_create_user.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_get_user.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_get_user.id,
  aws_api_gateway_integration.lambda_dev_chatbot_get_user.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_update_user.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_update_user.id,
  aws_api_gateway_integration.lambda_dev_chatbot_update_user.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_delete_user.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_delete_user.id,
  aws_api_gateway_integration.lambda_dev_chatbot_delete_user.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_create_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_create_chatbot.id,
  aws_api_gateway_integration.lambda_dev_chatbot_create_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_get_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_get_chatbot.id,
  aws_api_gateway_integration.lambda_dev_chatbot_get_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_update_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_update_chatbot.id,
  aws_api_gateway_integration.lambda_dev_chatbot_update_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_delete_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_delete_chatbot.id,
  aws_api_gateway_integration.lambda_dev_chatbot_delete_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_get_chat_history.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_get_chat_history.id,
  aws_api_gateway_integration.lambda_dev_chatbot_get_chat_history.id,
  
  aws_api_gateway_method.proxy_dev_chatbot_create_chat_history.resource_id,
  aws_api_gateway_method.proxy_dev_chatbot_create_chat_history.id,
  aws_api_gateway_integration.lambda_dev_chatbot_create_chat_history.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
