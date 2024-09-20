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