

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



resource "aws_api_gateway_rest_api" "api_gateway_dev_Delete-API-Test" {
  name        = "dev-Delete-API-Test"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_Delete-API-Test" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_Delete-API-Test.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_Delete-API-Test" {
  name = "lambda-role-dev-Delete-API-Test"
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

resource "aws_iam_policy" "labmda_policy_dev_Delete-API-Test" {
  name        = "lambda-policy-dev-Delete-API-Test"
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
      "Resource": "arn:aws:dynamodb:*:*:table/*"
    },
      {
        "Effect" : "Allow",
        "Action" : ["lambda:InvokeFunction"],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_Delete-API-Test" {
  policy_arn = aws_iam_policy.labmda_policy_dev_Delete-API-Test.arn
  role = aws_iam_role.lambda_role_dev_Delete-API-Test.name
}


resource "aws_dynamodb_table" "Delete-API-Test-dev-chatbot" {
  name           = "Delete-API-Test-dev-chatbot"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "chatbotId"

  attribute {
    name = "chatbotId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  lifecycle {
    ignore_changes = [ttl]
  }

  tags = {
    Name        = "Delete-API-Test-dev-chatbot"
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
function_name                  = "Delete-API-Test-dev-create_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Delete-API-Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Delete-API-Test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Delete-API-Test_create_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.root_resource_id}"
  path_part   = "create_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_Delete-API-Test_create_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Delete-API-Test_create_chatbot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Delete-API-Test_create_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id
  resource_id = aws_api_gateway_method.proxy_dev_Delete-API-Test_create_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Delete-API-Test_create_chatbot.http_method

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
function_name                  = "Delete-API-Test-dev-get_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Delete-API-Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Delete-API-Test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Delete-API-Test_get_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.root_resource_id}"
  path_part   = "get_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_Delete-API-Test_get_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Delete-API-Test_get_chatbot.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Delete-API-Test_get_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id
  resource_id = aws_api_gateway_method.proxy_dev_Delete-API-Test_get_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Delete-API-Test_get_chatbot.http_method

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
function_name                  = "Delete-API-Test-dev-update_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Delete-API-Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Delete-API-Test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Delete-API-Test_update_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.root_resource_id}"
  path_part   = "update_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_Delete-API-Test_update_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Delete-API-Test_update_chatbot.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Delete-API-Test_update_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id
  resource_id = aws_api_gateway_method.proxy_dev_Delete-API-Test_update_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Delete-API-Test_update_chatbot.http_method

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
function_name                  = "Delete-API-Test-dev-delete_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Delete-API-Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Delete-API-Test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Delete-API-Test_delete_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.root_resource_id}"
  path_part   = "delete_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_Delete-API-Test_delete_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Delete-API-Test_delete_chatbot.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Delete-API-Test_delete_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id
  resource_id = aws_api_gateway_method.proxy_dev_Delete-API-Test_delete_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Delete-API-Test_delete_chatbot.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_list_chatbots" {
type        = "zip"
source_dir  = "lambdas/list_chatbots"
output_path = "lambdas/list_chatbots.zip"
}

resource "aws_lambda_function" "lambda_dev_list_chatbots" {
filename                       = "lambdas/list_chatbots.zip"
function_name                  = "Delete-API-Test-dev-list_chatbots"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_list_chatbots.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Delete-API-Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Delete-API-Test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_list_chatbots" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_list_chatbots.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Delete-API-Test_list_chatbots" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.root_resource_id}"
  path_part   = "list_chatbots"
}

resource "aws_api_gateway_method" "proxy_dev_Delete-API-Test_list_chatbots" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Delete-API-Test_list_chatbots.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Delete-API-Test_list_chatbots" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id
  resource_id = aws_api_gateway_method.proxy_dev_Delete-API-Test_list_chatbots.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Delete-API-Test_list_chatbots.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_list_chatbots.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_Delete-API-Test" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Delete-API-Test.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_Delete-API-Test_create_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_Delete-API-Test_create_chatbot.id,
  aws_api_gateway_integration.lambda_dev_Delete-API-Test_create_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_Delete-API-Test_get_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_Delete-API-Test_get_chatbot.id,
  aws_api_gateway_integration.lambda_dev_Delete-API-Test_get_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_Delete-API-Test_update_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_Delete-API-Test_update_chatbot.id,
  aws_api_gateway_integration.lambda_dev_Delete-API-Test_update_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_Delete-API-Test_delete_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_Delete-API-Test_delete_chatbot.id,
  aws_api_gateway_integration.lambda_dev_Delete-API-Test_delete_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_Delete-API-Test_list_chatbots.resource_id,
  aws_api_gateway_method.proxy_dev_Delete-API-Test_list_chatbots.id,
  aws_api_gateway_integration.lambda_dev_Delete-API-Test_list_chatbots.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "api_invoke_url" {
  description = "The URL of the API endpoint"
  value = aws_api_gateway_deployment.api_gateway_dev_Delete-API-Test.invoke_url
}
