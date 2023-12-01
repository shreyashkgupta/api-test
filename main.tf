
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





resource "aws_api_gateway_rest_api" "api_gateway_Dev_testing_again" {
  name        = "Dev-testing_again"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_Dev_testing_again" {
  deployment_id = aws_api_gateway_deployment.api_gateway_Dev_testing_again.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id
  stage_name    = "Dev"
}



resource "aws_iam_role" "lambda_role_Dev_testing_again" {
  name = "lambda-role-Dev-testing_again"
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

resource "aws_iam_policy" "labmda_policy_Dev_testing_again" {
  name        = "lambda-policy-Dev-testing_again"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_Dev_testing_again" {
  policy_arn = aws_iam_policy.labmda_policy_Dev_testing_again.arn
  role = aws_iam_role.lambda_role_Dev_testing_again.name
}


resource "aws_dynamodb_table" "testing_again-Dev-UserTable" {
  name           = "testing_again-Dev-UserTable"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserTableId"

  attribute {
    name = "UserTableId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "testing_again-Dev-UserTable"
    Environment = "Dev"
  }
}


data "archive_file" "zip_the_python_code_Dev_createUser" {
type        = "zip"
source_dir  = "lambdas/createUser"
output_path = "lambdas/createUser.zip"
}

resource "aws_lambda_function" "lambda_Dev_createUser" {
filename                       = "lambdas/createUser.zip"
function_name                  = "testing_again-Dev-createUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_createUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_testing_again.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_testing_again]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_createUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_createUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_again_createUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.root_resource_id}"
  path_part   = "createuser"
}

resource "aws_api_gateway_method" "proxy_Dev_testing_again_createUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_again_createUser.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_testing_again_createUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id
  resource_id = aws_api_gateway_method.proxy_Dev_testing_again_createUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_testing_again_createUser.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_createUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_getUser" {
type        = "zip"
source_dir  = "lambdas/getUser"
output_path = "lambdas/getUser.zip"
}

resource "aws_lambda_function" "lambda_Dev_getUser" {
filename                       = "lambdas/getUser.zip"
function_name                  = "testing_again-Dev-getUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_getUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_testing_again.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_testing_again]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_getUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_getUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_again_getUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.root_resource_id}"
  path_part   = "getuser"
}

resource "aws_api_gateway_method" "proxy_Dev_testing_again_getUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_again_getUser.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_testing_again_getUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id
  resource_id = aws_api_gateway_method.proxy_Dev_testing_again_getUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_testing_again_getUser.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_getUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_updateUser" {
type        = "zip"
source_dir  = "lambdas/updateUser"
output_path = "lambdas/updateUser.zip"
}

resource "aws_lambda_function" "lambda_Dev_updateUser" {
filename                       = "lambdas/updateUser.zip"
function_name                  = "testing_again-Dev-updateUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_updateUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_testing_again.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_testing_again]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_updateUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_updateUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_again_updateUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.root_resource_id}"
  path_part   = "updateuser"
}

resource "aws_api_gateway_method" "proxy_Dev_testing_again_updateUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_again_updateUser.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_testing_again_updateUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id
  resource_id = aws_api_gateway_method.proxy_Dev_testing_again_updateUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_testing_again_updateUser.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_updateUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_deleteUser" {
type        = "zip"
source_dir  = "lambdas/deleteUser"
output_path = "lambdas/deleteUser.zip"
}

resource "aws_lambda_function" "lambda_Dev_deleteUser" {
filename                       = "lambdas/deleteUser.zip"
function_name                  = "testing_again-Dev-deleteUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_deleteUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_testing_again.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_testing_again]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_deleteUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_deleteUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_again_deleteUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.root_resource_id}"
  path_part   = "deleteuser"
}

resource "aws_api_gateway_method" "proxy_Dev_testing_again_deleteUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_again_deleteUser.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_testing_again_deleteUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id
  resource_id = aws_api_gateway_method.proxy_Dev_testing_again_deleteUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_testing_again_deleteUser.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_deleteUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_authenticateUser" {
type        = "zip"
source_dir  = "lambdas/authenticateUser"
output_path = "lambdas/authenticateUser.zip"
}

resource "aws_lambda_function" "lambda_Dev_authenticateUser" {
filename                       = "lambdas/authenticateUser.zip"
function_name                  = "testing_again-Dev-authenticateUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_authenticateUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_testing_again.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_testing_again]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_authenticateUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_authenticateUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_testing_again_authenticateUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.root_resource_id}"
  path_part   = "authenticateuser"
}

resource "aws_api_gateway_method" "proxy_Dev_testing_again_authenticateUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_testing_again_authenticateUser.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_testing_again_authenticateUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id
  resource_id = aws_api_gateway_method.proxy_Dev_testing_again_authenticateUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_testing_again_authenticateUser.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_authenticateUser.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_Dev_testing_again" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_testing_again.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_Dev_testing_again_createUser.resource_id,
  aws_api_gateway_method.proxy_Dev_testing_again_createUser.id,
  aws_api_gateway_integration.lambda_Dev_testing_again_createUser.id,
  
  aws_api_gateway_method.proxy_Dev_testing_again_getUser.resource_id,
  aws_api_gateway_method.proxy_Dev_testing_again_getUser.id,
  aws_api_gateway_integration.lambda_Dev_testing_again_getUser.id,
  
  aws_api_gateway_method.proxy_Dev_testing_again_updateUser.resource_id,
  aws_api_gateway_method.proxy_Dev_testing_again_updateUser.id,
  aws_api_gateway_integration.lambda_Dev_testing_again_updateUser.id,
  
  aws_api_gateway_method.proxy_Dev_testing_again_deleteUser.resource_id,
  aws_api_gateway_method.proxy_Dev_testing_again_deleteUser.id,
  aws_api_gateway_integration.lambda_Dev_testing_again_deleteUser.id,
  
  aws_api_gateway_method.proxy_Dev_testing_again_authenticateUser.resource_id,
  aws_api_gateway_method.proxy_Dev_testing_again_authenticateUser.id,
  aws_api_gateway_integration.lambda_Dev_testing_again_authenticateUser.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
