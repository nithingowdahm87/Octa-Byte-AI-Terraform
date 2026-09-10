resource "aws_sns_topic" "alarms" {
  name = "${var.project_name}-${var.environment}-alarms"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.py"
  output_path = "${path.module}/rollback_safety.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-rollback-safety"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy" "policy" {
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["ssm:GetParameter", "ssm:PutParameter"]
        Effect = "Allow"
        Resource = "arn:aws:ssm:*:*:parameter/${trimprefix(var.deployment_state_param, "/")}"
      },
      {
        Action = ["lambda:InvokeFunction"]
        Effect = "Allow"
        Resource = "arn:aws:lambda:*:*:function:${var.release_controller_func}"
      },
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "this" {
  function_name    = "${var.project_name}-${var.environment}-rollback-safety"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "python3.9"

  environment {
    variables = {
      DEPLOYMENT_STATE_PARAM  = var.deployment_state_param
      RELEASE_CONTROLLER_FUNC = var.release_controller_func
    }
  }
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarms.arn
}
