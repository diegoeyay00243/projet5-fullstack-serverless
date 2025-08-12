resource "aws_lambda_function" "contact" {
  filename         = var.lambda_zip_path
  function_name    = var.lambda_function_name
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  role             = aws_iam_role.lambda_exec.arn
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      EMAIL_SENDER   = var.email_sender
      EMAIL_PASSWORD = var.email_password
      EMAIL_RECEIVER = var.email_receiver
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
