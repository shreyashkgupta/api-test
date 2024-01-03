
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





resource "aws_api_gateway_rest_api" "api_gateway_dev_aws_token_testing_2" {
  name        = "dev-aws_token_testing_2"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_aws_token_testing_2" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_aws_token_testing_2.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_aws_token_testing_2" {
  name = "lambda-role-dev-aws_token_testing_2"
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

resource "aws_iam_policy" "labmda_policy_dev_aws_token_testing_2" {
  name        = "lambda-policy-dev-aws_token_testing_2"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_aws_token_testing_2" {
  policy_arn = aws_iam_policy.labmda_policy_dev_aws_token_testing_2.arn
  role = aws_iam_role.lambda_role_dev_aws_token_testing_2.name
}


resource "aws_dynamodb_table" "aws_token_testing_2-dev-chatbot_info" {
  name           = "aws_token_testing_2-dev-chatbot_info"
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
    Name        = "aws_token_testing_2-dev-chatbot_info"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "aws_token_testing_2-dev-chatbot_entity_info" {
  name           = "aws_token_testing_2-dev-chatbot_entity_info"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chatbot_entity_infoId"

  attribute {
    name = "chatbot_entity_infoId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "aws_token_testing_2-dev-chatbot_entity_info"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "aws_token_testing_2-dev-chatbot_intent_info" {
  name           = "aws_token_testing_2-dev-chatbot_intent_info"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "chatbot_intent_infoId"

  attribute {
    name = "chatbot_intent_infoId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "aws_token_testing_2-dev-chatbot_intent_info"
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
function_name                  = "aws_token_testing_2-dev-create_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_create_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "create_bot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_create_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_create_bot.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_create_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_bot.http_method

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
function_name                  = "aws_token_testing_2-dev-get_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_get_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "get_bot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_get_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_get_bot.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_get_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_bot.http_method

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
function_name                  = "aws_token_testing_2-dev-update_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_update_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "update_bot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_update_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_update_bot.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_update_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_bot.http_method

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
function_name                  = "aws_token_testing_2-dev-delete_bot"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_bot.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_bot" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_bot.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_delete_bot" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "delete_bot"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_delete_bot" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_delete_bot.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_delete_bot" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_bot.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_bot.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_bot.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_all_bots" {
type        = "zip"
source_dir  = "lambdas/get_all_bots"
output_path = "lambdas/get_all_bots.zip"
}

resource "aws_lambda_function" "lambda_dev_get_all_bots" {
filename                       = "lambdas/get_all_bots.zip"
function_name                  = "aws_token_testing_2-dev-get_all_bots"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_all_bots.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_all_bots" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_all_bots.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_get_all_bots" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "get_all_bots"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_get_all_bots" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_get_all_bots.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_get_all_bots" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_bots.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_bots.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_all_bots.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_intent" {
type        = "zip"
source_dir  = "lambdas/create_intent"
output_path = "lambdas/create_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_create_intent" {
filename                       = "lambdas/create_intent.zip"
function_name                  = "aws_token_testing_2-dev-create_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_create_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "create_intent"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_create_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_create_intent.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_create_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_intent.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_intent" {
type        = "zip"
source_dir  = "lambdas/get_intent"
output_path = "lambdas/get_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_get_intent" {
filename                       = "lambdas/get_intent.zip"
function_name                  = "aws_token_testing_2-dev-get_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_get_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "get_intent"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_get_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_get_intent.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_get_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_intent.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_intent" {
type        = "zip"
source_dir  = "lambdas/update_intent"
output_path = "lambdas/update_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_update_intent" {
filename                       = "lambdas/update_intent.zip"
function_name                  = "aws_token_testing_2-dev-update_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_update_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "update_intent"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_update_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_update_intent.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_update_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_intent.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_delete_intent" {
type        = "zip"
source_dir  = "lambdas/delete_intent"
output_path = "lambdas/delete_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_delete_intent" {
filename                       = "lambdas/delete_intent.zip"
function_name                  = "aws_token_testing_2-dev-delete_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_delete_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "delete_intent"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_delete_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_delete_intent.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_delete_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_intent.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_all_intents" {
type        = "zip"
source_dir  = "lambdas/get_all_intents"
output_path = "lambdas/get_all_intents.zip"
}

resource "aws_lambda_function" "lambda_dev_get_all_intents" {
filename                       = "lambdas/get_all_intents.zip"
function_name                  = "aws_token_testing_2-dev-get_all_intents"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_all_intents.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_all_intents" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_all_intents.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_get_all_intents" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "get_all_intents"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_get_all_intents" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_get_all_intents.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_get_all_intents" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_intents.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_intents.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_all_intents.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_entity" {
type        = "zip"
source_dir  = "lambdas/create_entity"
output_path = "lambdas/create_entity.zip"
}

resource "aws_lambda_function" "lambda_dev_create_entity" {
filename                       = "lambdas/create_entity.zip"
function_name                  = "aws_token_testing_2-dev-create_entity"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_entity.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_entity" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_entity.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_create_entity" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "create_entity"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_create_entity" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_create_entity.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_create_entity" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_entity.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_entity.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_entity.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_entity" {
type        = "zip"
source_dir  = "lambdas/get_entity"
output_path = "lambdas/get_entity.zip"
}

resource "aws_lambda_function" "lambda_dev_get_entity" {
filename                       = "lambdas/get_entity.zip"
function_name                  = "aws_token_testing_2-dev-get_entity"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_entity.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_entity" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_entity.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_get_entity" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "get_entity"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_get_entity" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_get_entity.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_get_entity" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_entity.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_entity.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_entity.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_entity" {
type        = "zip"
source_dir  = "lambdas/update_entity"
output_path = "lambdas/update_entity.zip"
}

resource "aws_lambda_function" "lambda_dev_update_entity" {
filename                       = "lambdas/update_entity.zip"
function_name                  = "aws_token_testing_2-dev-update_entity"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_entity.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_entity" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_entity.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_update_entity" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "update_entity"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_update_entity" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_update_entity.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_update_entity" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_entity.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_entity.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_entity.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_delete_entity" {
type        = "zip"
source_dir  = "lambdas/delete_entity"
output_path = "lambdas/delete_entity.zip"
}

resource "aws_lambda_function" "lambda_dev_delete_entity" {
filename                       = "lambdas/delete_entity.zip"
function_name                  = "aws_token_testing_2-dev-delete_entity"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_entity.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_entity" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_entity.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_delete_entity" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "delete_entity"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_delete_entity" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_delete_entity.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_delete_entity" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_entity.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_entity.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_entity.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_all_entities" {
type        = "zip"
source_dir  = "lambdas/get_all_entities"
output_path = "lambdas/get_all_entities.zip"
}

resource "aws_lambda_function" "lambda_dev_get_all_entities" {
filename                       = "lambdas/get_all_entities.zip"
function_name                  = "aws_token_testing_2-dev-get_all_entities"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_all_entities.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws_token_testing_2.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws_token_testing_2]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_all_entities" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_all_entities.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws_token_testing_2_get_all_entities" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.root_resource_id}"
  path_part   = "get_all_entities"
}

resource "aws_api_gateway_method" "proxy_dev_aws_token_testing_2_get_all_entities" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws_token_testing_2_get_all_entities.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws_token_testing_2_get_all_entities" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id
  resource_id = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_entities.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_entities.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_all_entities.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_aws_token_testing_2" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws_token_testing_2.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_bot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_bot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_create_bot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_bot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_bot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_get_bot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_bot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_bot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_update_bot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_bot.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_bot.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_delete_bot.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_bots.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_bots.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_get_all_bots.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_intent.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_intent.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_create_intent.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_intent.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_intent.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_get_intent.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_intent.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_intent.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_update_intent.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_intent.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_intent.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_delete_intent.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_intents.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_intents.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_get_all_intents.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_entity.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_create_entity.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_create_entity.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_entity.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_entity.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_get_entity.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_entity.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_update_entity.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_update_entity.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_entity.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_delete_entity.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_delete_entity.id,
  
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_entities.resource_id,
  aws_api_gateway_method.proxy_dev_aws_token_testing_2_get_all_entities.id,
  aws_api_gateway_integration.lambda_dev_aws_token_testing_2_get_all_entities.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
