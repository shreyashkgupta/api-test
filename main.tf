
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





resource "aws_api_gateway_rest_api" "api_gateway_dev_aws_token_testing_1" {
  name        = "dev-aws_token_testing_1"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_aws_token_testing_1" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_aws_token_testing_1.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_aws_token_testing_1" {
  name = "lambda-role-dev-aws_token_testing_1"
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

resource "aws_iam_policy" "labmda_policy_dev_aws_token_testing_1" {
  name        = "lambda-policy-dev-aws_token_testing_1"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_aws_token_testing_1" {
  policy_arn = aws_iam_policy.labmda_policy_dev_aws_token_testing_1.arn
  role = aws_iam_role.lambda_role_dev_aws_token_testing_1.name
}


resource "aws_dynamodb_table" "aws_token_testing_1-dev-chatbot_db" {
  name           = "aws_token_testing_1-dev-chatbot_db"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chatbot_dbId"

  attribute {
    name = "chatbot_dbId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "aws_token_testing_1-dev-chatbot_db"
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
function_name                  = "aws_token_testing_1-dev-create_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_1_create_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.root_resource_id}"
  path_part   = "create_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_1_create_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_1_create_chatbot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_1_create_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_1_create_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_1_create_chatbot.http_method

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
function_name                  = "aws_token_testing_1-dev-get_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_1_get_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.root_resource_id}"
  path_part   = "get_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_1_get_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_1_get_chatbot.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_1_get_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_chatbot.http_method

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
function_name                  = "aws_token_testing_1-dev-update_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_1_update_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.root_resource_id}"
  path_part   = "update_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_1_update_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_1_update_chatbot.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_1_update_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_1_update_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_1_update_chatbot.http_method

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
function_name                  = "aws_token_testing_1-dev-delete_chatbot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_chatbot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_chatbot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_chatbot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_1_delete_chatbot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.root_resource_id}"
  path_part   = "delete_chatbot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_1_delete_chatbot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_1_delete_chatbot.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_1_delete_chatbot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_1_delete_chatbot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_1_delete_chatbot.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_chatbot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_all_chatbots" {
type        = "zip"
source_dir  = "lambdas/get_all_chatbots"
output_path = "lambdas/get_all_chatbots.zip"
}

resource "aws_lambda_function" "lambda_dev_get_all_chatbots" {
filename                       = "lambdas/get_all_chatbots.zip"
function_name                  = "aws_token_testing_1-dev-get_all_chatbots"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_all_chatbots.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_all_chatbots" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_all_chatbots.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_1_get_all_chatbots" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.root_resource_id}"
  path_part   = "get_all_chatbots"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_1_get_all_chatbots" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_1_get_all_chatbots.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_1_get_all_chatbots" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_all_chatbots.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_all_chatbots.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_all_chatbots.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_aws_token_testing_1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_1.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_create_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_create_chatbot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_1_create_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_chatbot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_1_get_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_update_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_update_chatbot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_1_update_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_delete_chatbot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_delete_chatbot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_1_delete_chatbot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_all_chatbots.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_1_get_all_chatbots.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_1_get_all_chatbots.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
