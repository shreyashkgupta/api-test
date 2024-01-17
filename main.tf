
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





resource "aws_api_gateway_rest_api" "api_gateway_Dev_awstest" {
  name        = "Dev-awstest"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_Dev_awstest" {
  deployment_id = aws_api_gateway_deployment.api_gateway_Dev_awstest.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_Dev_awstest.id
  stage_name    = "Dev"
}



resource "aws_iam_role" "lambda_role_Dev_awstest" {
  name = "lambda-role-Dev-awstest"
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

resource "aws_iam_policy" "labmda_policy_Dev_awstest" {
  name        = "lambda-policy-Dev-awstest"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_Dev_awstest" {
  policy_arn = aws_iam_policy.labmda_policy_Dev_awstest.arn
  role = aws_iam_role.lambda_role_Dev_awstest.name
}


resource "aws_dynamodb_table" "awstest-Dev-users" {
  name           = "awstest-Dev-users"
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
    Name        = "awstest-Dev-users"
    Environment = "Dev"
  }
}


data "archive_file" "zip_the_python_code_Dev_create_user" {
type        = "zip"
source_dir  = "lambdas/create_user"
output_path = "lambdas/create_user.zip"
}

resource "aws_lambda_function" "lambda_Dev_create_user" {
filename                       = "lambdas/create_user.zip"
function_name                  = "awstest-Dev-create_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_create_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_awstest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_awstest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_create_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_create_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_awstest_create_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.root_resource_id}"
  path_part   = "create_user"
}

resource "aws_api_gateway_method" "proxy_Dev_awstest_create_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_awstest_create_user.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_awstest_create_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_awstest.id
  resource_id = aws_api_gateway_method.proxy_Dev_awstest_create_user.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_awstest_create_user.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_create_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_get_user" {
type        = "zip"
source_dir  = "lambdas/get_user"
output_path = "lambdas/get_user.zip"
}

resource "aws_lambda_function" "lambda_Dev_get_user" {
filename                       = "lambdas/get_user.zip"
function_name                  = "awstest-Dev-get_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_get_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_awstest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_awstest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_get_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_get_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_awstest_get_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.root_resource_id}"
  path_part   = "get_user"
}

resource "aws_api_gateway_method" "proxy_Dev_awstest_get_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_awstest_get_user.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_awstest_get_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_awstest.id
  resource_id = aws_api_gateway_method.proxy_Dev_awstest_get_user.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_awstest_get_user.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_get_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_update_user" {
type        = "zip"
source_dir  = "lambdas/update_user"
output_path = "lambdas/update_user.zip"
}

resource "aws_lambda_function" "lambda_Dev_update_user" {
filename                       = "lambdas/update_user.zip"
function_name                  = "awstest-Dev-update_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_update_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_awstest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_awstest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_update_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_update_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_awstest_update_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.root_resource_id}"
  path_part   = "update_user"
}

resource "aws_api_gateway_method" "proxy_Dev_awstest_update_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_awstest_update_user.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_awstest_update_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_awstest.id
  resource_id = aws_api_gateway_method.proxy_Dev_awstest_update_user.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_awstest_update_user.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_update_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_delete_user" {
type        = "zip"
source_dir  = "lambdas/delete_user"
output_path = "lambdas/delete_user.zip"
}

resource "aws_lambda_function" "lambda_Dev_delete_user" {
filename                       = "lambdas/delete_user.zip"
function_name                  = "awstest-Dev-delete_user"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_delete_user.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_awstest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_awstest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_delete_user" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_delete_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_awstest_delete_user" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.root_resource_id}"
  path_part   = "delete_user"
}

resource "aws_api_gateway_method" "proxy_Dev_awstest_delete_user" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_awstest_delete_user.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_awstest_delete_user" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_awstest.id
  resource_id = aws_api_gateway_method.proxy_Dev_awstest_delete_user.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_awstest_delete_user.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_delete_user.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_list_users" {
type        = "zip"
source_dir  = "lambdas/list_users"
output_path = "lambdas/list_users.zip"
}

resource "aws_lambda_function" "lambda_Dev_list_users" {
filename                       = "lambdas/list_users.zip"
function_name                  = "awstest-Dev-list_users"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_list_users.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_awstest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_awstest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_list_users" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_list_users.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_awstest_list_users" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.root_resource_id}"
  path_part   = "list_users"
}

resource "aws_api_gateway_method" "proxy_Dev_awstest_list_users" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_awstest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_awstest_list_users.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_awstest_list_users" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_awstest.id
  resource_id = aws_api_gateway_method.proxy_Dev_awstest_list_users.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_awstest_list_users.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_list_users.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_Dev_awstest" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_awstest.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_Dev_awstest_create_user.resource_id,
  aws_api_gateway_method.proxy_Dev_awstest_create_user.id,
  aws_api_gateway_integration.lambda_Dev_awstest_create_user.id,
  
  aws_api_gateway_method.proxy_Dev_awstest_get_user.resource_id,
  aws_api_gateway_method.proxy_Dev_awstest_get_user.id,
  aws_api_gateway_integration.lambda_Dev_awstest_get_user.id,
  
  aws_api_gateway_method.proxy_Dev_awstest_update_user.resource_id,
  aws_api_gateway_method.proxy_Dev_awstest_update_user.id,
  aws_api_gateway_integration.lambda_Dev_awstest_update_user.id,
  
  aws_api_gateway_method.proxy_Dev_awstest_delete_user.resource_id,
  aws_api_gateway_method.proxy_Dev_awstest_delete_user.id,
  aws_api_gateway_integration.lambda_Dev_awstest_delete_user.id,
  
  aws_api_gateway_method.proxy_Dev_awstest_list_users.resource_id,
  aws_api_gateway_method.proxy_Dev_awstest_list_users.id,
  aws_api_gateway_integration.lambda_Dev_awstest_list_users.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
