

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



resource "aws_api_gateway_rest_api" "api_gateway_dev_aws-testing" {
  name        = "dev-aws-testing"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_aws-testing" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_aws-testing.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_aws-testing" {
  name = "lambda-role-dev-aws-testing"
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

resource "aws_iam_policy" "labmda_policy_dev_aws-testing" {
  name        = "lambda-policy-dev-aws-testing"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_aws-testing" {
  policy_arn = aws_iam_policy.labmda_policy_dev_aws-testing.arn
  role = aws_iam_role.lambda_role_dev_aws-testing.name
}


resource "aws_dynamodb_table" "aws-testing-dev-users" {
  name           = "aws-testing-dev-users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "usersId"

  attribute {
    name = "usersId"
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
    Name        = "aws-testing-dev-users"
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
function_name                  = "aws-testing-dev-create_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_create_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws-testing.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws-testing]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_create_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws-testing_create_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.root_resource_id}"
  path_part   = "create_user"
}

resource "aws_api_gateway_method" "proxy_dev_aws-testing_create_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws-testing_create_user.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws-testing_create_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id
  resource_id = aws_api_gateway_method.proxy_dev_aws-testing_create_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws-testing_create_user.http_method

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
function_name                  = "aws-testing-dev-get_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_get_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws-testing.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws-testing]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_get_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws-testing_get_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.root_resource_id}"
  path_part   = "get_user"
}

resource "aws_api_gateway_method" "proxy_dev_aws-testing_get_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws-testing_get_user.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws-testing_get_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id
  resource_id = aws_api_gateway_method.proxy_dev_aws-testing_get_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws-testing_get_user.http_method

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
function_name                  = "aws-testing-dev-update_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_update_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws-testing.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws-testing]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_update_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_update_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws-testing_update_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.root_resource_id}"
  path_part   = "update_user"
}

resource "aws_api_gateway_method" "proxy_dev_aws-testing_update_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws-testing_update_user.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws-testing_update_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id
  resource_id = aws_api_gateway_method.proxy_dev_aws-testing_update_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws-testing_update_user.http_method

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
function_name                  = "aws-testing-dev-delete_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_delete_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws-testing.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws-testing]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_delete_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_delete_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws-testing_delete_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.root_resource_id}"
  path_part   = "delete_user"
}

resource "aws_api_gateway_method" "proxy_dev_aws-testing_delete_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws-testing_delete_user.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws-testing_delete_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id
  resource_id = aws_api_gateway_method.proxy_dev_aws-testing_delete_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws-testing_delete_user.http_method

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
function_name                  = "aws-testing-dev-list_users"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_list_users.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws-testing.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws-testing]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_list_users" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_list_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws-testing_list_users" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.root_resource_id}"
  path_part   = "list_users"
}

resource "aws_api_gateway_method" "proxy_dev_aws-testing_list_users" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws-testing_list_users.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws-testing_list_users" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id
  resource_id = aws_api_gateway_method.proxy_dev_aws-testing_list_users.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws-testing_list_users.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_list_users.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_authenticate_user" {
type        = "zip"
source_dir  = "lambdas/authenticate_user"
output_path = "lambdas/authenticate_user.zip"
}

resource "aws_lambda_function" "lambda_dev_authenticate_user" {
filename                       = "lambdas/authenticate_user.zip"
function_name                  = "aws-testing-dev-authenticate_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_authenticate_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_aws-testing.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_aws-testing]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_authenticate_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_authenticate_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_aws-testing_authenticate_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.root_resource_id}"
  path_part   = "authenticate_user"
}

resource "aws_api_gateway_method" "proxy_dev_aws-testing_authenticate_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_aws-testing_authenticate_user.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_aws-testing_authenticate_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id
  resource_id = aws_api_gateway_method.proxy_dev_aws-testing_authenticate_user.resource_id
  http_method = aws_api_gateway_method.proxy_dev_aws-testing_authenticate_user.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_authenticate_user.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_aws-testing" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_aws-testing.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_aws-testing_create_user.resource_id,
  aws_api_gateway_method.proxy_dev_aws-testing_create_user.id,
  aws_api_gateway_integration.lambda_dev_aws-testing_create_user.id,
  
  aws_api_gateway_method.proxy_dev_aws-testing_get_user.resource_id,
  aws_api_gateway_method.proxy_dev_aws-testing_get_user.id,
  aws_api_gateway_integration.lambda_dev_aws-testing_get_user.id,
  
  aws_api_gateway_method.proxy_dev_aws-testing_update_user.resource_id,
  aws_api_gateway_method.proxy_dev_aws-testing_update_user.id,
  aws_api_gateway_integration.lambda_dev_aws-testing_update_user.id,
  
  aws_api_gateway_method.proxy_dev_aws-testing_delete_user.resource_id,
  aws_api_gateway_method.proxy_dev_aws-testing_delete_user.id,
  aws_api_gateway_integration.lambda_dev_aws-testing_delete_user.id,
  
  aws_api_gateway_method.proxy_dev_aws-testing_list_users.resource_id,
  aws_api_gateway_method.proxy_dev_aws-testing_list_users.id,
  aws_api_gateway_integration.lambda_dev_aws-testing_list_users.id,
  
  aws_api_gateway_method.proxy_dev_aws-testing_authenticate_user.resource_id,
  aws_api_gateway_method.proxy_dev_aws-testing_authenticate_user.id,
  aws_api_gateway_integration.lambda_dev_aws-testing_authenticate_user.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "api_invoke_url" {
  description = "The URL of the API endpoint"
  value = aws_api_gateway_deployment.api_gateway_dev_aws-testing.invoke_url
}
