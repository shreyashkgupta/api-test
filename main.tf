
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





resource "aws_api_gateway_rest_api" "api_gateway_Dev_dp_Test" {
  name        = "Dev-dp_Test"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_Dev_dp_Test" {
  deployment_id = aws_api_gateway_deployment.api_gateway_Dev_dp_Test.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  stage_name    = "Dev"
}



resource "aws_iam_role" "lambda_role_Dev_dp_Test" {
  name = "lambda-role-Dev-dp_Test"
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

resource "aws_iam_policy" "labmda_policy_Dev_dp_Test" {
  name        = "lambda-policy-Dev-dp_Test"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_Dev_dp_Test" {
  policy_arn = aws_iam_policy.labmda_policy_Dev_dp_Test.arn
  role = aws_iam_role.lambda_role_Dev_dp_Test.name
}


resource "aws_dynamodb_table" "dp_Test-Dev-User" {
  name           = "dp_Test-Dev-User"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "dp_Test-Dev-User"
    Environment = "Dev"
  }
}



resource "aws_dynamodb_table" "dp_Test-Dev-UserRole" {
  name           = "dp_Test-Dev-UserRole"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserRoleId"

  attribute {
    name = "UserRoleId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "dp_Test-Dev-UserRole"
    Environment = "Dev"
  }
}



resource "aws_dynamodb_table" "dp_Test-Dev-Role" {
  name           = "dp_Test-Dev-Role"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "RoleId"

  attribute {
    name = "RoleId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "dp_Test-Dev-Role"
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
function_name                  = "dp_Test-Dev-createUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_createUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_createUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_createUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_createUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "createuser"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_createUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_createUser.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_createUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_createUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_createUser.http_method

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
function_name                  = "dp_Test-Dev-getUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_getUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_getUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_getUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_getUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "getuser"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_getUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_getUser.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_getUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_getUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_getUser.http_method

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
function_name                  = "dp_Test-Dev-updateUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_updateUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_updateUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_updateUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_updateUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "updateuser"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_updateUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_updateUser.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_updateUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_updateUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_updateUser.http_method

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
function_name                  = "dp_Test-Dev-deleteUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_deleteUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_deleteUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_deleteUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_deleteUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "deleteuser"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_deleteUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_deleteUser.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_deleteUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_deleteUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_deleteUser.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_deleteUser.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_listUsers" {
type        = "zip"
source_dir  = "lambdas/listUsers"
output_path = "lambdas/listUsers.zip"
}

resource "aws_lambda_function" "lambda_Dev_listUsers" {
filename                       = "lambdas/listUsers.zip"
function_name                  = "dp_Test-Dev-listUsers"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_listUsers.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_listUsers" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_listUsers.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_listUsers" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "listusers"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_listUsers" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_listUsers.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_listUsers" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_listUsers.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_listUsers.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_listUsers.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_createRole" {
type        = "zip"
source_dir  = "lambdas/createRole"
output_path = "lambdas/createRole.zip"
}

resource "aws_lambda_function" "lambda_Dev_createRole" {
filename                       = "lambdas/createRole.zip"
function_name                  = "dp_Test-Dev-createRole"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_createRole.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_createRole" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_createRole.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_createRole" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "createrole"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_createRole" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_createRole.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_createRole" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_createRole.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_createRole.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_createRole.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_getRole" {
type        = "zip"
source_dir  = "lambdas/getRole"
output_path = "lambdas/getRole.zip"
}

resource "aws_lambda_function" "lambda_Dev_getRole" {
filename                       = "lambdas/getRole.zip"
function_name                  = "dp_Test-Dev-getRole"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_getRole.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_getRole" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_getRole.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_getRole" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "getrole"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_getRole" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_getRole.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_getRole" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_getRole.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_getRole.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_getRole.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_updateRole" {
type        = "zip"
source_dir  = "lambdas/updateRole"
output_path = "lambdas/updateRole.zip"
}

resource "aws_lambda_function" "lambda_Dev_updateRole" {
filename                       = "lambdas/updateRole.zip"
function_name                  = "dp_Test-Dev-updateRole"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_updateRole.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_updateRole" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_updateRole.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_updateRole" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "updaterole"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_updateRole" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_updateRole.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_updateRole" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_updateRole.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_updateRole.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_updateRole.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_deleteRole" {
type        = "zip"
source_dir  = "lambdas/deleteRole"
output_path = "lambdas/deleteRole.zip"
}

resource "aws_lambda_function" "lambda_Dev_deleteRole" {
filename                       = "lambdas/deleteRole.zip"
function_name                  = "dp_Test-Dev-deleteRole"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_deleteRole.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_deleteRole" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_deleteRole.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_deleteRole" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "deleterole"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_deleteRole" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_deleteRole.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_deleteRole" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_deleteRole.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_deleteRole.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_deleteRole.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_listRoles" {
type        = "zip"
source_dir  = "lambdas/listRoles"
output_path = "lambdas/listRoles.zip"
}

resource "aws_lambda_function" "lambda_Dev_listRoles" {
filename                       = "lambdas/listRoles.zip"
function_name                  = "dp_Test-Dev-listRoles"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_listRoles.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_listRoles" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_listRoles.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_listRoles" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "listroles"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_listRoles" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_listRoles.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_listRoles" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_listRoles.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_listRoles.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_listRoles.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_addUserToRole" {
type        = "zip"
source_dir  = "lambdas/addUserToRole"
output_path = "lambdas/addUserToRole.zip"
}

resource "aws_lambda_function" "lambda_Dev_addUserToRole" {
filename                       = "lambdas/addUserToRole.zip"
function_name                  = "dp_Test-Dev-addUserToRole"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_addUserToRole.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_addUserToRole" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_addUserToRole.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_addUserToRole" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "addusertorole"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_addUserToRole" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_addUserToRole.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_addUserToRole" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_addUserToRole.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_addUserToRole.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_addUserToRole.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_removeUserFromRole" {
type        = "zip"
source_dir  = "lambdas/removeUserFromRole"
output_path = "lambdas/removeUserFromRole.zip"
}

resource "aws_lambda_function" "lambda_Dev_removeUserFromRole" {
filename                       = "lambdas/removeUserFromRole.zip"
function_name                  = "dp_Test-Dev-removeUserFromRole"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_removeUserFromRole.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_removeUserFromRole" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_removeUserFromRole.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_removeUserFromRole" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "removeuserfromrole"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_removeUserFromRole" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_removeUserFromRole.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_removeUserFromRole" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_removeUserFromRole.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_removeUserFromRole.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_removeUserFromRole.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_listUsersInRole" {
type        = "zip"
source_dir  = "lambdas/listUsersInRole"
output_path = "lambdas/listUsersInRole.zip"
}

resource "aws_lambda_function" "lambda_Dev_listUsersInRole" {
filename                       = "lambdas/listUsersInRole.zip"
function_name                  = "dp_Test-Dev-listUsersInRole"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_listUsersInRole.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_dp_Test.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_dp_Test]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_listUsersInRole" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_listUsersInRole.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_dp_Test_listUsersInRole" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.root_resource_id}"
  path_part   = "listusersinrole"
}

resource "aws_api_gateway_method" "proxy_Dev_dp_Test_listUsersInRole" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_dp_Test_listUsersInRole.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_dp_Test_listUsersInRole" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id
  resource_id = aws_api_gateway_method.proxy_Dev_dp_Test_listUsersInRole.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_dp_Test_listUsersInRole.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_listUsersInRole.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_Dev_dp_Test" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_dp_Test.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_Dev_dp_Test_createUser.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_createUser.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_createUser.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_getUser.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_getUser.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_getUser.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_updateUser.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_updateUser.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_updateUser.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_deleteUser.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_deleteUser.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_deleteUser.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_listUsers.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_listUsers.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_listUsers.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_createRole.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_createRole.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_createRole.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_getRole.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_getRole.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_getRole.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_updateRole.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_updateRole.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_updateRole.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_deleteRole.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_deleteRole.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_deleteRole.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_listRoles.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_listRoles.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_listRoles.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_addUserToRole.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_addUserToRole.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_addUserToRole.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_removeUserFromRole.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_removeUserFromRole.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_removeUserFromRole.id,
  
  aws_api_gateway_method.proxy_Dev_dp_Test_listUsersInRole.resource_id,
  aws_api_gateway_method.proxy_Dev_dp_Test_listUsersInRole.id,
  aws_api_gateway_integration.lambda_Dev_dp_Test_listUsersInRole.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
