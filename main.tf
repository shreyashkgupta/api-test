

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



resource "aws_api_gateway_rest_api" "api_gateway_dev_testing_3" {
  name        = "dev-testing_3"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_testing_3" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_testing_3.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_testing_3" {
  name = "lambda-role-dev-testing_3"
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

resource "aws_iam_policy" "labmda_policy_dev_testing_3" {
  name        = "lambda-policy-dev-testing_3"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_testing_3" {
  policy_arn = aws_iam_policy.labmda_policy_dev_testing_3.arn
  role = aws_iam_role.lambda_role_dev_testing_3.name
}


resource "aws_dynamodb_table" "testing_3-dev-chatbots" {
  name           = "testing_3-dev-chatbots"
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
    Name        = "testing_3-dev-chatbots"
    Environment = "dev"
  }
}


data "archive_file" "zip_the_python_code_dev_create_bot" {
type        = "zip"
source_dir  = "lambdas/create_bot"
output_path = "lambdas/create_bot.zip"
}

resource "aws_lambda_function" "lambda_dev_create_bot" {
filename                       = "lambdas/create_bot.zip"
function_name                  = "testing_3-dev-create_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_3.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_3]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_3_create_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.root_resource_id}"
  path_part   = "create_bot"
}

resource "aws_api_gateway_method" "proxy_dev_testing_3_create_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_3_create_bot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_3_create_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_3_create_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_3_create_bot.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_bot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_bot" {
type        = "zip"
source_dir  = "lambdas/get_bot"
output_path = "lambdas/get_bot.zip"
}

resource "aws_lambda_function" "lambda_dev_get_bot" {
filename                       = "lambdas/get_bot.zip"
function_name                  = "testing_3-dev-get_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_3.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_3]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_3_get_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.root_resource_id}"
  path_part   = "get_bot"
}

resource "aws_api_gateway_method" "proxy_dev_testing_3_get_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_3_get_bot.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_3_get_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_3_get_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_3_get_bot.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_bot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_bot" {
type        = "zip"
source_dir  = "lambdas/update_bot"
output_path = "lambdas/update_bot.zip"
}

resource "aws_lambda_function" "lambda_dev_update_bot" {
filename                       = "lambdas/update_bot.zip"
function_name                  = "testing_3-dev-update_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_3.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_3]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_3_update_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.root_resource_id}"
  path_part   = "update_bot"
}

resource "aws_api_gateway_method" "proxy_dev_testing_3_update_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_3_update_bot.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_3_update_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_3_update_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_3_update_bot.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_bot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_delete_bot" {
type        = "zip"
source_dir  = "lambdas/delete_bot"
output_path = "lambdas/delete_bot.zip"
}

resource "aws_lambda_function" "lambda_dev_delete_bot" {
filename                       = "lambdas/delete_bot.zip"
function_name                  = "testing_3-dev-delete_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_3.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_3]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_3_delete_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.root_resource_id}"
  path_part   = "delete_bot"
}

resource "aws_api_gateway_method" "proxy_dev_testing_3_delete_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_3_delete_bot.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_3_delete_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_3_delete_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_3_delete_bot.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_bot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_send_message" {
type        = "zip"
source_dir  = "lambdas/send_message"
output_path = "lambdas/send_message.zip"
}

resource "aws_lambda_function" "lambda_dev_send_message" {
filename                       = "lambdas/send_message.zip"
function_name                  = "testing_3-dev-send_message"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_send_message.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_3.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_3]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_send_message" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_send_message.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_3_send_message" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.root_resource_id}"
  path_part   = "send_message"
}

resource "aws_api_gateway_method" "proxy_dev_testing_3_send_message" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_3_send_message.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_3_send_message" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_3_send_message.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_3_send_message.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_send_message.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_conversations" {
type        = "zip"
source_dir  = "lambdas/get_conversations"
output_path = "lambdas/get_conversations.zip"
}

resource "aws_lambda_function" "lambda_dev_get_conversations" {
filename                       = "lambdas/get_conversations.zip"
function_name                  = "testing_3-dev-get_conversations"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_conversations.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_3.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_3]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_conversations" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_conversations.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_3_get_conversations" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.root_resource_id}"
  path_part   = "get_conversations"
}

resource "aws_api_gateway_method" "proxy_dev_testing_3_get_conversations" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_3.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_3_get_conversations.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_3_get_conversations" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_3_get_conversations.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_3_get_conversations.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_conversations.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_testing_3" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_3.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_testing_3_create_bot.resource_id,
  aws_api_gateway_method.proxy_dev_testing_3_create_bot.id,
  aws_api_gateway_integration.lambda_dev_testing_3_create_bot.id,
  
  aws_api_gateway_method.proxy_dev_testing_3_get_bot.resource_id,
  aws_api_gateway_method.proxy_dev_testing_3_get_bot.id,
  aws_api_gateway_integration.lambda_dev_testing_3_get_bot.id,
  
  aws_api_gateway_method.proxy_dev_testing_3_update_bot.resource_id,
  aws_api_gateway_method.proxy_dev_testing_3_update_bot.id,
  aws_api_gateway_integration.lambda_dev_testing_3_update_bot.id,
  
  aws_api_gateway_method.proxy_dev_testing_3_delete_bot.resource_id,
  aws_api_gateway_method.proxy_dev_testing_3_delete_bot.id,
  aws_api_gateway_integration.lambda_dev_testing_3_delete_bot.id,
  
  aws_api_gateway_method.proxy_dev_testing_3_send_message.resource_id,
  aws_api_gateway_method.proxy_dev_testing_3_send_message.id,
  aws_api_gateway_integration.lambda_dev_testing_3_send_message.id,
  
  aws_api_gateway_method.proxy_dev_testing_3_get_conversations.resource_id,
  aws_api_gateway_method.proxy_dev_testing_3_get_conversations.id,
  aws_api_gateway_integration.lambda_dev_testing_3_get_conversations.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
