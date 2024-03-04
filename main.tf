

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



resource "aws_api_gateway_rest_api" "api_gateway_dev_Stripe-Demo" {
  name        = "dev-Stripe-Demo"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_Stripe-Demo" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_Stripe-Demo.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_Stripe-Demo" {
  name = "lambda-role-dev-Stripe-Demo"
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

resource "aws_iam_policy" "labmda_policy_dev_Stripe-Demo" {
  name        = "lambda-policy-dev-Stripe-Demo"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_Stripe-Demo" {
  policy_arn = aws_iam_policy.labmda_policy_dev_Stripe-Demo.arn
  role = aws_iam_role.lambda_role_dev_Stripe-Demo.name
}


resource "aws_dynamodb_table" "Stripe-Demo-dev-subscriptions" {
  name           = "Stripe-Demo-dev-subscriptions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "subscriptionsId"

  attribute {
    name = "subscriptionsId"
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
    Name        = "Stripe-Demo-dev-subscriptions"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "Stripe-Demo-dev-customers" {
  name           = "Stripe-Demo-dev-customers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "customersId"

  attribute {
    name = "customersId"
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
    Name        = "Stripe-Demo-dev-customers"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "Stripe-Demo-dev-payment_intents" {
  name           = "Stripe-Demo-dev-payment_intents"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "payment_intentsId"

  attribute {
    name = "payment_intentsId"
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
    Name        = "Stripe-Demo-dev-payment_intents"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "Stripe-Demo-dev-payment_methods" {
  name           = "Stripe-Demo-dev-payment_methods"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "payment_methodsId"

  attribute {
    name = "payment_methodsId"
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
    Name        = "Stripe-Demo-dev-payment_methods"
    Environment = "dev"
  }
}


data "archive_file" "zip_the_python_code_dev_create_customer" {
type        = "zip"
source_dir  = "lambdas/create_customer"
output_path = "lambdas/create_customer.zip"
}

resource "aws_lambda_function" "lambda_dev_create_customer" {
filename                       = "lambdas/create_customer.zip"
function_name                  = "Stripe-Demo-dev-create_customer"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_customer.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_customer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_customer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_create_customer" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "create_customer"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_create_customer" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_create_customer.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_create_customer" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_customer.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_customer.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_customer.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_retrieve_customer" {
type        = "zip"
source_dir  = "lambdas/retrieve_customer"
output_path = "lambdas/retrieve_customer.zip"
}

resource "aws_lambda_function" "lambda_dev_retrieve_customer" {
filename                       = "lambdas/retrieve_customer.zip"
function_name                  = "Stripe-Demo-dev-retrieve_customer"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_retrieve_customer.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_retrieve_customer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_retrieve_customer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_retrieve_customer" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "retrieve_customer"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_retrieve_customer" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_retrieve_customer.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_retrieve_customer" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_customer.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_customer.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_retrieve_customer.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_customer" {
type        = "zip"
source_dir  = "lambdas/update_customer"
output_path = "lambdas/update_customer.zip"
}

resource "aws_lambda_function" "lambda_dev_update_customer" {
filename                       = "lambdas/update_customer.zip"
function_name                  = "Stripe-Demo-dev-update_customer"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_customer.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_customer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_customer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_update_customer" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "update_customer"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_update_customer" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_update_customer.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_update_customer" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_update_customer.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_update_customer.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_customer.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_delete_customer" {
type        = "zip"
source_dir  = "lambdas/delete_customer"
output_path = "lambdas/delete_customer.zip"
}

resource "aws_lambda_function" "lambda_dev_delete_customer" {
filename                       = "lambdas/delete_customer.zip"
function_name                  = "Stripe-Demo-dev-delete_customer"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_customer.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_customer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_customer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_delete_customer" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "delete_customer"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_delete_customer" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_delete_customer.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_delete_customer" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_delete_customer.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_delete_customer.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_customer.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_payment_intent" {
type        = "zip"
source_dir  = "lambdas/create_payment_intent"
output_path = "lambdas/create_payment_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_create_payment_intent" {
filename                       = "lambdas/create_payment_intent.zip"
function_name                  = "Stripe-Demo-dev-create_payment_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_payment_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_payment_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_payment_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_create_payment_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "create_payment_intent"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_create_payment_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_create_payment_intent.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_create_payment_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_payment_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_retrieve_payment_intent" {
type        = "zip"
source_dir  = "lambdas/retrieve_payment_intent"
output_path = "lambdas/retrieve_payment_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_retrieve_payment_intent" {
filename                       = "lambdas/retrieve_payment_intent.zip"
function_name                  = "Stripe-Demo-dev-retrieve_payment_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_retrieve_payment_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_retrieve_payment_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_retrieve_payment_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_retrieve_payment_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "retrieve_payment_intent"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_retrieve_payment_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_retrieve_payment_intent.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_retrieve_payment_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_intent.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_retrieve_payment_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_confirm_payment_intent" {
type        = "zip"
source_dir  = "lambdas/confirm_payment_intent"
output_path = "lambdas/confirm_payment_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_confirm_payment_intent" {
filename                       = "lambdas/confirm_payment_intent.zip"
function_name                  = "Stripe-Demo-dev-confirm_payment_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_confirm_payment_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_confirm_payment_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_confirm_payment_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_confirm_payment_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "confirm_payment_intent"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_confirm_payment_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_confirm_payment_intent.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_confirm_payment_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_confirm_payment_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_confirm_payment_intent.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_confirm_payment_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_cancel_payment_intent" {
type        = "zip"
source_dir  = "lambdas/cancel_payment_intent"
output_path = "lambdas/cancel_payment_intent.zip"
}

resource "aws_lambda_function" "lambda_dev_cancel_payment_intent" {
filename                       = "lambdas/cancel_payment_intent.zip"
function_name                  = "Stripe-Demo-dev-cancel_payment_intent"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_cancel_payment_intent.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_cancel_payment_intent" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_cancel_payment_intent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_cancel_payment_intent" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "cancel_payment_intent"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_cancel_payment_intent" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_cancel_payment_intent.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_cancel_payment_intent" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_payment_intent.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_payment_intent.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_cancel_payment_intent.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_payment_method" {
type        = "zip"
source_dir  = "lambdas/create_payment_method"
output_path = "lambdas/create_payment_method.zip"
}

resource "aws_lambda_function" "lambda_dev_create_payment_method" {
filename                       = "lambdas/create_payment_method.zip"
function_name                  = "Stripe-Demo-dev-create_payment_method"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_payment_method.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_payment_method" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_payment_method.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_create_payment_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "create_payment_method"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_create_payment_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_create_payment_method.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_create_payment_method" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_method.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_payment_method.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_retrieve_payment_method" {
type        = "zip"
source_dir  = "lambdas/retrieve_payment_method"
output_path = "lambdas/retrieve_payment_method.zip"
}

resource "aws_lambda_function" "lambda_dev_retrieve_payment_method" {
filename                       = "lambdas/retrieve_payment_method.zip"
function_name                  = "Stripe-Demo-dev-retrieve_payment_method"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_retrieve_payment_method.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_retrieve_payment_method" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_retrieve_payment_method.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_retrieve_payment_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "retrieve_payment_method"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_retrieve_payment_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_retrieve_payment_method.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_retrieve_payment_method" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_method.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_method.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_retrieve_payment_method.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_payment_method" {
type        = "zip"
source_dir  = "lambdas/update_payment_method"
output_path = "lambdas/update_payment_method.zip"
}

resource "aws_lambda_function" "lambda_dev_update_payment_method" {
filename                       = "lambdas/update_payment_method.zip"
function_name                  = "Stripe-Demo-dev-update_payment_method"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_payment_method.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_payment_method" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_payment_method.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_update_payment_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "update_payment_method"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_update_payment_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_update_payment_method.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_update_payment_method" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_update_payment_method.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_update_payment_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_payment_method.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_attach_payment_method" {
type        = "zip"
source_dir  = "lambdas/attach_payment_method"
output_path = "lambdas/attach_payment_method.zip"
}

resource "aws_lambda_function" "lambda_dev_attach_payment_method" {
filename                       = "lambdas/attach_payment_method.zip"
function_name                  = "Stripe-Demo-dev-attach_payment_method"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_attach_payment_method.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_attach_payment_method" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_attach_payment_method.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_attach_payment_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "attach_payment_method"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_attach_payment_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_attach_payment_method.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_attach_payment_method" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_attach_payment_method.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_attach_payment_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_attach_payment_method.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_detach_payment_method" {
type        = "zip"
source_dir  = "lambdas/detach_payment_method"
output_path = "lambdas/detach_payment_method.zip"
}

resource "aws_lambda_function" "lambda_dev_detach_payment_method" {
filename                       = "lambdas/detach_payment_method.zip"
function_name                  = "Stripe-Demo-dev-detach_payment_method"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_detach_payment_method.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_detach_payment_method" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_detach_payment_method.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_detach_payment_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "detach_payment_method"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_detach_payment_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_detach_payment_method.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_detach_payment_method" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_detach_payment_method.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_detach_payment_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_detach_payment_method.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_payment_intent_payment_method" {
type        = "zip"
source_dir  = "lambdas/create_payment_intent_payment_method"
output_path = "lambdas/create_payment_intent_payment_method.zip"
}

resource "aws_lambda_function" "lambda_dev_create_payment_intent_payment_method" {
filename                       = "lambdas/create_payment_intent_payment_method.zip"
function_name                  = "Stripe-Demo-dev-create_payment_intent_payment_method"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_payment_intent_payment_method.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_payment_intent_payment_method" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_payment_intent_payment_method.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_create_payment_intent_payment_method" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "create_payment_intent_payment_method"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_create_payment_intent_payment_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_create_payment_intent_payment_method.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_create_payment_intent_payment_method" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_payment_method.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_payment_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_payment_intent_payment_method.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_payment_intent_customer" {
type        = "zip"
source_dir  = "lambdas/create_payment_intent_customer"
output_path = "lambdas/create_payment_intent_customer.zip"
}

resource "aws_lambda_function" "lambda_dev_create_payment_intent_customer" {
filename                       = "lambdas/create_payment_intent_customer.zip"
function_name                  = "Stripe-Demo-dev-create_payment_intent_customer"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_payment_intent_customer.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_payment_intent_customer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_payment_intent_customer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_create_payment_intent_customer" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "create_payment_intent_customer"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_create_payment_intent_customer" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_create_payment_intent_customer.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_create_payment_intent_customer" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_customer.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_customer.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_payment_intent_customer.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_subscription" {
type        = "zip"
source_dir  = "lambdas/create_subscription"
output_path = "lambdas/create_subscription.zip"
}

resource "aws_lambda_function" "lambda_dev_create_subscription" {
filename                       = "lambdas/create_subscription.zip"
function_name                  = "Stripe-Demo-dev-create_subscription"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_subscription.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_subscription" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_subscription.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_create_subscription" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "create_subscription"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_create_subscription" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_create_subscription.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_create_subscription" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_subscription.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_create_subscription.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_subscription.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_retrieve_subscription" {
type        = "zip"
source_dir  = "lambdas/retrieve_subscription"
output_path = "lambdas/retrieve_subscription.zip"
}

resource "aws_lambda_function" "lambda_dev_retrieve_subscription" {
filename                       = "lambdas/retrieve_subscription.zip"
function_name                  = "Stripe-Demo-dev-retrieve_subscription"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_retrieve_subscription.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_retrieve_subscription" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_retrieve_subscription.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_retrieve_subscription" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "retrieve_subscription"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_retrieve_subscription" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_retrieve_subscription.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_retrieve_subscription" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_subscription.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_subscription.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_retrieve_subscription.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_subscription" {
type        = "zip"
source_dir  = "lambdas/update_subscription"
output_path = "lambdas/update_subscription.zip"
}

resource "aws_lambda_function" "lambda_dev_update_subscription" {
filename                       = "lambdas/update_subscription.zip"
function_name                  = "Stripe-Demo-dev-update_subscription"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_subscription.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_subscription" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_subscription.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_update_subscription" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "update_subscription"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_update_subscription" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_update_subscription.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_update_subscription" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_update_subscription.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_update_subscription.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_subscription.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_cancel_subscription" {
type        = "zip"
source_dir  = "lambdas/cancel_subscription"
output_path = "lambdas/cancel_subscription.zip"
}

resource "aws_lambda_function" "lambda_dev_cancel_subscription" {
filename                       = "lambdas/cancel_subscription.zip"
function_name                  = "Stripe-Demo-dev-cancel_subscription"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_cancel_subscription.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_Stripe-Demo.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_Stripe-Demo]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_cancel_subscription" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_cancel_subscription.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_Stripe-Demo_cancel_subscription" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.root_resource_id}"
  path_part   = "cancel_subscription"
}

resource "aws_api_gateway_method" "proxy_dev_Stripe-Demo_cancel_subscription" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_Stripe-Demo_cancel_subscription.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_Stripe-Demo_cancel_subscription" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id
  resource_id = aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_subscription.resource_id
  http_method = aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_subscription.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_cancel_subscription.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_Stripe-Demo" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_Stripe-Demo.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_customer.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_customer.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_create_customer.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_customer.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_customer.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_retrieve_customer.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_update_customer.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_update_customer.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_update_customer.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_delete_customer.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_delete_customer.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_delete_customer.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_create_payment_intent.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_intent.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_intent.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_retrieve_payment_intent.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_confirm_payment_intent.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_confirm_payment_intent.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_confirm_payment_intent.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_payment_intent.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_payment_intent.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_cancel_payment_intent.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_method.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_method.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_create_payment_method.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_method.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_payment_method.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_retrieve_payment_method.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_update_payment_method.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_update_payment_method.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_update_payment_method.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_attach_payment_method.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_attach_payment_method.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_attach_payment_method.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_detach_payment_method.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_detach_payment_method.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_detach_payment_method.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_payment_method.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_payment_method.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_create_payment_intent_payment_method.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_customer.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_payment_intent_customer.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_create_payment_intent_customer.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_subscription.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_create_subscription.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_create_subscription.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_subscription.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_retrieve_subscription.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_retrieve_subscription.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_update_subscription.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_update_subscription.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_update_subscription.id,
  
  aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_subscription.resource_id,
  aws_api_gateway_method.proxy_dev_Stripe-Demo_cancel_subscription.id,
  aws_api_gateway_integration.lambda_dev_Stripe-Demo_cancel_subscription.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "api_invoke_url" {
  description = "The URL of the API endpoint"
  value = aws_api_gateway_deployment.api_gateway_dev_Stripe-Demo.invoke_url
}
