

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



resource "aws_api_gateway_rest_api" "api_gateway_dev_testing_1" {
  name        = "dev-testing_1"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_testing_1" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_testing_1.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_testing_1" {
  name = "lambda-role-dev-testing_1"
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

resource "aws_iam_policy" "labmda_policy_dev_testing_1" {
  name        = "lambda-policy-dev-testing_1"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_testing_1" {
  policy_arn = aws_iam_policy.labmda_policy_dev_testing_1.arn
  role = aws_iam_role.lambda_role_dev_testing_1.name
}


resource "aws_dynamodb_table" "testing_1-dev-users" {
  name           = "testing_1-dev-users"
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
    Name        = "testing_1-dev-users"
    Environment = "dev"
  }
}



resource "aws_dynamodb_table" "testing_1-dev-groups" {
  name           = "testing_1-dev-groups"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "groupsId"

  attribute {
    name = "groupsId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "testing_1-dev-groups"
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
function_name                  = "testing_1-dev-create_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_create_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "create_user"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_create_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_create_user.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_create_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_create_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_create_user.http_method

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
function_name                  = "testing_1-dev-get_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_get_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "get_user"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_get_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_get_user.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_get_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_get_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_get_user.http_method

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
function_name                  = "testing_1-dev-update_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_update_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "update_user"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_update_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_update_user.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_update_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_update_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_update_user.http_method

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
function_name                  = "testing_1-dev-delete_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_delete_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "delete_user"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_delete_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_delete_user.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_delete_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_delete_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_delete_user.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_list_users" {
type        = "zip"
source_dir  = "lambdas/list_users"
output_path = "lambdas/list_users.zip"
}

resource "aws_lambda_function" "lambda_dev_list_users" {
filename                       = "lambdas/list_users.zip"
function_name                  = "testing_1-dev-list_users"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_list_users.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_list_users" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_list_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_list_users" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "list_users"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_list_users" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_list_users.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_list_users" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_list_users.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_list_users.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_list_users.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_create_group" {
type        = "zip"
source_dir  = "lambdas/create_group"
output_path = "lambdas/create_group.zip"
}

resource "aws_lambda_function" "lambda_dev_create_group" {
filename                       = "lambdas/create_group.zip"
function_name                  = "testing_1-dev-create_group"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_group.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_group" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_group.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_create_group" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "create_group"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_create_group" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_create_group.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_create_group" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_create_group.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_create_group.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_create_group.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_get_group" {
type        = "zip"
source_dir  = "lambdas/get_group"
output_path = "lambdas/get_group.zip"
}

resource "aws_lambda_function" "lambda_dev_get_group" {
filename                       = "lambdas/get_group.zip"
function_name                  = "testing_1-dev-get_group"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_group.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_group" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_group.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_get_group" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "get_group"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_get_group" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_get_group.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_get_group" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_get_group.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_get_group.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_get_group.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_update_group" {
type        = "zip"
source_dir  = "lambdas/update_group"
output_path = "lambdas/update_group.zip"
}

resource "aws_lambda_function" "lambda_dev_update_group" {
filename                       = "lambdas/update_group.zip"
function_name                  = "testing_1-dev-update_group"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_group.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_group" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_group.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_update_group" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "update_group"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_update_group" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_update_group.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_update_group" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_update_group.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_update_group.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_update_group.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_delete_group" {
type        = "zip"
source_dir  = "lambdas/delete_group"
output_path = "lambdas/delete_group.zip"
}

resource "aws_lambda_function" "lambda_dev_delete_group" {
filename                       = "lambdas/delete_group.zip"
function_name                  = "testing_1-dev-delete_group"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_group.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_group" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_group.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_delete_group" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "delete_group"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_delete_group" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_delete_group.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_delete_group" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_delete_group.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_delete_group.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_delete_group.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_list_groups" {
type        = "zip"
source_dir  = "lambdas/list_groups"
output_path = "lambdas/list_groups.zip"
}

resource "aws_lambda_function" "lambda_dev_list_groups" {
filename                       = "lambdas/list_groups.zip"
function_name                  = "testing_1-dev-list_groups"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_list_groups.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_testing_1.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_testing_1]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_list_groups" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_list_groups.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_1_list_groups" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.root_resource_id}"
  path_part   = "list_groups"
}

resource "aws_api_gateway_method" "proxy_dev_testing_1_list_groups" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_testing_1.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_1_list_groups.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_testing_1_list_groups" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id
  resource_id = aws_api_gateway_method.proxy_dev_testing_1_list_groups.resource_id
  http_method = aws_api_gateway_method.proxy_dev_testing_1_list_groups.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_list_groups.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_testing_1" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_testing_1.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_testing_1_create_user.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_create_user.id,
  aws_api_gateway_integration.lambda_dev_testing_1_create_user.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_get_user.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_get_user.id,
  aws_api_gateway_integration.lambda_dev_testing_1_get_user.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_update_user.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_update_user.id,
  aws_api_gateway_integration.lambda_dev_testing_1_update_user.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_delete_user.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_delete_user.id,
  aws_api_gateway_integration.lambda_dev_testing_1_delete_user.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_list_users.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_list_users.id,
  aws_api_gateway_integration.lambda_dev_testing_1_list_users.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_create_group.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_create_group.id,
  aws_api_gateway_integration.lambda_dev_testing_1_create_group.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_get_group.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_get_group.id,
  aws_api_gateway_integration.lambda_dev_testing_1_get_group.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_update_group.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_update_group.id,
  aws_api_gateway_integration.lambda_dev_testing_1_update_group.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_delete_group.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_delete_group.id,
  aws_api_gateway_integration.lambda_dev_testing_1_delete_group.id,
  
  aws_api_gateway_method.proxy_dev_testing_1_list_groups.resource_id,
  aws_api_gateway_method.proxy_dev_testing_1_list_groups.id,
  aws_api_gateway_integration.lambda_dev_testing_1_list_groups.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
