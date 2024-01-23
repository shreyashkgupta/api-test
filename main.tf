

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
  region = "us-west-2"
}



resource "aws_api_gateway_rest_api" "api_gateway_dev_region_test" {
  name        = "dev-region_test"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_dev_region_test" {
  deployment_id = aws_api_gateway_deployment.api_gateway_dev_region_test.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_dev_region_test.id
  stage_name    = "dev"
}



resource "aws_iam_role" "lambda_role_dev_region_test" {
  name = "lambda-role-dev-region_test"
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

resource "aws_iam_policy" "labmda_policy_dev_region_test" {
  name        = "lambda-policy-dev-region_test"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_dev_region_test" {
  policy_arn = aws_iam_policy.labmda_policy_dev_region_test.arn
  role = aws_iam_role.lambda_role_dev_region_test.name
}


resource "aws_dynamodb_table" "region_test-dev-user_table" {
  name           = "region_test-dev-user_table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "user_tableId"

  attribute {
    name = "user_tableId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "region_test-dev-user_table"
    Environment = "dev"
  }
}


data "archive_file" "zip_the_python_code_dev_createUser" {
type        = "zip"
source_dir  = "lambdas/createUser"
output_path = "lambdas/createUser.zip"
}

resource "aws_lambda_function" "lambda_dev_createUser" {
filename                       = "lambdas/createUser.zip"
function_name                  = "region_test-dev-createUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_createUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_region_test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_region_test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_createUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_createUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_region_test_createUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.root_resource_id}"
  path_part   = "createuser"
}

resource "aws_api_gateway_method" "proxy_dev_region_test_createUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_region_test_createUser.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_region_test_createUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_region_test.id
  resource_id = aws_api_gateway_method.proxy_dev_region_test_createUser.resource_id
  http_method = aws_api_gateway_method.proxy_dev_region_test_createUser.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_createUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_getUser" {
type        = "zip"
source_dir  = "lambdas/getUser"
output_path = "lambdas/getUser.zip"
}

resource "aws_lambda_function" "lambda_dev_getUser" {
filename                       = "lambdas/getUser.zip"
function_name                  = "region_test-dev-getUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_getUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_region_test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_region_test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_getUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_getUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_region_test_getUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.root_resource_id}"
  path_part   = "getuser"
}

resource "aws_api_gateway_method" "proxy_dev_region_test_getUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_region_test_getUser.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_region_test_getUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_region_test.id
  resource_id = aws_api_gateway_method.proxy_dev_region_test_getUser.resource_id
  http_method = aws_api_gateway_method.proxy_dev_region_test_getUser.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_getUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_updateUser" {
type        = "zip"
source_dir  = "lambdas/updateUser"
output_path = "lambdas/updateUser.zip"
}

resource "aws_lambda_function" "lambda_dev_updateUser" {
filename                       = "lambdas/updateUser.zip"
function_name                  = "region_test-dev-updateUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_updateUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_region_test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_region_test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_updateUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_updateUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_region_test_updateUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.root_resource_id}"
  path_part   = "updateuser"
}

resource "aws_api_gateway_method" "proxy_dev_region_test_updateUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_region_test_updateUser.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_region_test_updateUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_region_test.id
  resource_id = aws_api_gateway_method.proxy_dev_region_test_updateUser.resource_id
  http_method = aws_api_gateway_method.proxy_dev_region_test_updateUser.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_updateUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_dev_deleteUser" {
type        = "zip"
source_dir  = "lambdas/deleteUser"
output_path = "lambdas/deleteUser.zip"
}

resource "aws_lambda_function" "lambda_dev_deleteUser" {
filename                       = "lambdas/deleteUser.zip"
function_name                  = "region_test-dev-deleteUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_dev_deleteUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_dev_region_test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_dev_region_test]
}

resource "aws_lambda_permission" "allow_api_gateway_dev_deleteUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_dev_deleteUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_region_test_deleteUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.root_resource_id}"
  path_part   = "deleteuser"
}

resource "aws_api_gateway_method" "proxy_dev_region_test_deleteUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_dev_region_test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_region_test_deleteUser.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_dev_region_test_deleteUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_region_test.id
  resource_id = aws_api_gateway_method.proxy_dev_region_test_deleteUser.resource_id
  http_method = aws_api_gateway_method.proxy_dev_region_test_deleteUser.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_dev_deleteUser.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_dev_region_test" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_dev_region_test.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_dev_region_test_createUser.resource_id,
  aws_api_gateway_method.proxy_dev_region_test_createUser.id,
  aws_api_gateway_integration.lambda_dev_region_test_createUser.id,
  
  aws_api_gateway_method.proxy_dev_region_test_getUser.resource_id,
  aws_api_gateway_method.proxy_dev_region_test_getUser.id,
  aws_api_gateway_integration.lambda_dev_region_test_getUser.id,
  
  aws_api_gateway_method.proxy_dev_region_test_updateUser.resource_id,
  aws_api_gateway_method.proxy_dev_region_test_updateUser.id,
  aws_api_gateway_integration.lambda_dev_region_test_updateUser.id,
  
  aws_api_gateway_method.proxy_dev_region_test_deleteUser.resource_id,
  aws_api_gateway_method.proxy_dev_region_test_deleteUser.id,
  aws_api_gateway_integration.lambda_dev_region_test_deleteUser.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
