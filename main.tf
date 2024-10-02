data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = var.archive_file.source_file
  output_path = var.archive_file.output_path
}

resource "aws_lambda_function" "lambda_func" {
  filename      = data.archive_file.lambda.filename
  function_name = var.lambda_function.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_function.handler

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = var.lambda_function.runtime

  environment {
    variables = var.env_vars
  }
}

resource "aws_api_gateway_rest_api" "this" {
  name = var.api_gateway_name
}

resource "aws_api_gateway_authorizer" "gateway_auth" {
  name = "Api Autherizer"
  rest_api_id = aws_api_gateway_rest_api.this.id
  type = "COGNITO_USER_POOLS"
  provider_arns = "some_arn"
}

resource "aws_api_gateway_resource" "gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id = aws_api_gateway_rest_api.this.root_resource_id
  path_part = "user"
}

resource "aws_api_gateway_method" "gateway_method" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.gateway_resource.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.gateway_auth.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.gateway_resource.id
  http_method = aws_api_gateway_method.gateway_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.lambda_func.image_uri
}

resource "aws_lambda_permission" "lambda_perms" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_func.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}:/*/${aws_api_gateway_method.gateway_method.http_method}${aws_api_gateway_resource.gateway_resource.path}"
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  triggers = {
    force_redeploy = timestamp()
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}

resource "aws_api_gateway_stage" "gatewat_stage" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id
  stage_name = "dev"
}

