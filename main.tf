
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





resource "aws_api_gateway_rest_api" "api_gateway_Dev_apiTest" {
  name        = "Dev-apiTest"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_stage" "api_gateway_Dev_apiTest" {
  deployment_id = aws_api_gateway_deployment.api_gateway_Dev_apiTest.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  stage_name    = "Dev"
}



resource "aws_iam_role" "lambda_role_Dev_apiTest" {
  name = "lambda-role-Dev-apiTest"
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

resource "aws_iam_policy" "labmda_policy_Dev_apiTest" {
  name        = "lambda-policy-Dev-apiTest"
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

resource "aws_iam_role_policy_attachment" "lambda_policy_Dev_apiTest" {
  policy_arn = aws_iam_policy.labmda_policy_Dev_apiTest.arn
  role = aws_iam_role.lambda_role_Dev_apiTest.name
}


resource "aws_dynamodb_table" "apiTest-Dev-User" {
  name           = "apiTest-Dev-User"
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
    Name        = "apiTest-Dev-User"
    Environment = "Dev"
  }
}



resource "aws_dynamodb_table" "apiTest-Dev-Group" {
  name           = "apiTest-Dev-Group"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "GroupId"

  attribute {
    name = "GroupId"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = false
  }

  tags = {
    Name        = "apiTest-Dev-Group"
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
function_name                  = "apiTest-Dev-createUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_createUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_createUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_createUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_createUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "createuser"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_createUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_createUser.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_createUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_createUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_createUser.http_method

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
function_name                  = "apiTest-Dev-getUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_getUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_getUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_getUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_getUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "getuser"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_getUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_getUser.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_getUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_getUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_getUser.http_method

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
function_name                  = "apiTest-Dev-updateUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_updateUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_updateUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_updateUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_updateUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "updateuser"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_updateUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_updateUser.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_updateUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_updateUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_updateUser.http_method

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
function_name                  = "apiTest-Dev-deleteUser"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_deleteUser.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_deleteUser" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_deleteUser.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_deleteUser" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "deleteuser"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_deleteUser" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_deleteUser.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_deleteUser" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_deleteUser.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_deleteUser.http_method

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
function_name                  = "apiTest-Dev-listUsers"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_listUsers.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_listUsers" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_listUsers.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_listUsers" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "listusers"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_listUsers" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_listUsers.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_listUsers" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_listUsers.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_listUsers.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_listUsers.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_createGroup" {
type        = "zip"
source_dir  = "lambdas/createGroup"
output_path = "lambdas/createGroup.zip"
}

resource "aws_lambda_function" "lambda_Dev_createGroup" {
filename                       = "lambdas/createGroup.zip"
function_name                  = "apiTest-Dev-createGroup"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_createGroup.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_createGroup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_createGroup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_createGroup" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "creategroup"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_createGroup" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_createGroup.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_createGroup" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_createGroup.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_createGroup.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_createGroup.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_getGroup" {
type        = "zip"
source_dir  = "lambdas/getGroup"
output_path = "lambdas/getGroup.zip"
}

resource "aws_lambda_function" "lambda_Dev_getGroup" {
filename                       = "lambdas/getGroup.zip"
function_name                  = "apiTest-Dev-getGroup"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_getGroup.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_getGroup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_getGroup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_getGroup" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "getgroup"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_getGroup" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_getGroup.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_getGroup" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_getGroup.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_getGroup.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_getGroup.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_updateGroup" {
type        = "zip"
source_dir  = "lambdas/updateGroup"
output_path = "lambdas/updateGroup.zip"
}

resource "aws_lambda_function" "lambda_Dev_updateGroup" {
filename                       = "lambdas/updateGroup.zip"
function_name                  = "apiTest-Dev-updateGroup"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_updateGroup.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_updateGroup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_updateGroup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_updateGroup" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "updategroup"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_updateGroup" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_updateGroup.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_updateGroup" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_updateGroup.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_updateGroup.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_updateGroup.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_deleteGroup" {
type        = "zip"
source_dir  = "lambdas/deleteGroup"
output_path = "lambdas/deleteGroup.zip"
}

resource "aws_lambda_function" "lambda_Dev_deleteGroup" {
filename                       = "lambdas/deleteGroup.zip"
function_name                  = "apiTest-Dev-deleteGroup"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_deleteGroup.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_deleteGroup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_deleteGroup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_deleteGroup" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "deletegroup"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_deleteGroup" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_deleteGroup.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_deleteGroup" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_deleteGroup.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_deleteGroup.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_deleteGroup.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_listGroups" {
type        = "zip"
source_dir  = "lambdas/listGroups"
output_path = "lambdas/listGroups.zip"
}

resource "aws_lambda_function" "lambda_Dev_listGroups" {
filename                       = "lambdas/listGroups.zip"
function_name                  = "apiTest-Dev-listGroups"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_listGroups.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_listGroups" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_listGroups.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_listGroups" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "listgroups"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_listGroups" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_listGroups.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_listGroups" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_listGroups.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_listGroups.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_listGroups.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_addUserToGroup" {
type        = "zip"
source_dir  = "lambdas/addUserToGroup"
output_path = "lambdas/addUserToGroup.zip"
}

resource "aws_lambda_function" "lambda_Dev_addUserToGroup" {
filename                       = "lambdas/addUserToGroup.zip"
function_name                  = "apiTest-Dev-addUserToGroup"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_addUserToGroup.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_addUserToGroup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_addUserToGroup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_addUserToGroup" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "addusertogroup"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_addUserToGroup" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_addUserToGroup.id}"
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_addUserToGroup" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_addUserToGroup.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_addUserToGroup.http_method

  integration_http_method = "PUT"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_addUserToGroup.invoke_arn}"
}

data "archive_file" "zip_the_python_code_Dev_removeUserFromGroup" {
type        = "zip"
source_dir  = "lambdas/removeUserFromGroup"
output_path = "lambdas/removeUserFromGroup.zip"
}

resource "aws_lambda_function" "lambda_Dev_removeUserFromGroup" {
filename                       = "lambdas/removeUserFromGroup.zip"
function_name                  = "apiTest-Dev-removeUserFromGroup"
source_code_hash  = "${data.archive_file.zip_the_python_code_Dev_removeUserFromGroup.output_base64sha256}"
role                           = aws_iam_role.lambda_role_Dev_apiTest.arn
handler                        = "handler.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.lambda_policy_Dev_apiTest]
}

resource "aws_lambda_permission" "allow_api_gateway_Dev_removeUserFromGroup" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_Dev_removeUserFromGroup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.execution_arn}/*"
}


resource "aws_api_gateway_resource" "proxy_apiTest_removeUserFromGroup" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.root_resource_id}"
  path_part   = "removeuserfromgroup"
}

resource "aws_api_gateway_method" "proxy_Dev_apiTest_removeUserFromGroup" {
  rest_api_id   = "${aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id}"
  resource_id   = "${aws_api_gateway_resource.proxy_apiTest_removeUserFromGroup.id}"
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_Dev_apiTest_removeUserFromGroup" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id
  resource_id = aws_api_gateway_method.proxy_Dev_apiTest_removeUserFromGroup.resource_id
  http_method = aws_api_gateway_method.proxy_Dev_apiTest_removeUserFromGroup.http_method

  integration_http_method = "DELETE"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda_Dev_removeUserFromGroup.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_gateway_Dev_apiTest" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_Dev_apiTest.id

  triggers = {
   redeployment = sha1(
      jsonencode( [
  aws_api_gateway_method.proxy_Dev_apiTest_createUser.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_createUser.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_createUser.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_getUser.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_getUser.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_getUser.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_updateUser.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_updateUser.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_updateUser.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_deleteUser.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_deleteUser.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_deleteUser.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_listUsers.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_listUsers.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_listUsers.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_createGroup.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_createGroup.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_createGroup.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_getGroup.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_getGroup.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_getGroup.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_updateGroup.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_updateGroup.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_updateGroup.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_deleteGroup.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_deleteGroup.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_deleteGroup.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_listGroups.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_listGroups.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_listGroups.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_addUserToGroup.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_addUserToGroup.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_addUserToGroup.id,
  
  aws_api_gateway_method.proxy_Dev_apiTest_removeUserFromGroup.resource_id,
  aws_api_gateway_method.proxy_Dev_apiTest_removeUserFromGroup.id,
  aws_api_gateway_integration.lambda_Dev_apiTest_removeUserFromGroup.id,
  ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
