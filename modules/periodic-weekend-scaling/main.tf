
# We use EventBridge Scheduler + Lambda for periodic scaling to avoid cron expressions.
resource "aws_iam_role" "weekend_lambda_role" {
  count = var.weekend_scaling_enabled ? 1 : 0
  name  = "${var.project_name}-${var.environment}-weekend-scaling-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "weekend_lambda_policy" {
  count = var.weekend_scaling_enabled ? 1 : 0
  name  = "${var.project_name}-${var.environment}-weekend-scaling-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["autoscaling:UpdateAutoScalingGroup"]
        Effect   = "Allow"
        Resource = "*" # Restrict to specific ASG ARN in prod
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "weekend_lambda_attach" {
  count      = var.weekend_scaling_enabled ? 1 : 0
  role       = aws_iam_role.weekend_lambda_role[0].name
  policy_arn = aws_iam_policy.weekend_lambda_policy[0].arn
}

data "archive_file" "weekend_lambda_zip" {
  count       = var.weekend_scaling_enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.root}/../../lambda/weekend-scaling"
  output_path = "${path.module}/weekend-scaling.zip"
}

resource "aws_lambda_function" "weekend_scaling" {
  count            = var.weekend_scaling_enabled ? 1 : 0
  filename         = data.archive_file.weekend_lambda_zip[0].output_path
  function_name    = "${var.project_name}-${var.environment}-weekend-scaling"
  role             = aws_iam_role.weekend_lambda_role[0].arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.weekend_lambda_zip[0].output_base64sha256
  runtime          = "python3.10"
  timeout          = 30

  environment {
    variables = {
      ASG_NAME        = var.asg_name
      WEEKEND_MIN     = var.weekend_min_size
      WEEKEND_DESIRED = var.weekend_desired_capacity
      WEEKEND_MAX     = var.weekend_max_size
      NORMAL_MIN      = var.normal_min_size
      NORMAL_DESIRED  = var.normal_desired_capacity
      NORMAL_MAX      = var.normal_max_size
    }
  }

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-weekend-scaling" })
}

# EventBridge Scheduler to trigger the lambda at weekend_start_time with rate
resource "aws_iam_role" "scheduler_role" {
  count = var.weekend_scaling_enabled ? 1 : 0
  name  = "${var.project_name}-${var.environment}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "scheduler_policy" {
  count = var.weekend_scaling_enabled ? 1 : 0
  name  = "${var.project_name}-${var.environment}-scheduler-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["lambda:InvokeFunction"]
        Effect   = "Allow"
        Resource = aws_lambda_function.weekend_scaling[0].arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler_attach" {
  count      = var.weekend_scaling_enabled ? 1 : 0
  role       = aws_iam_role.scheduler_role[0].name
  policy_arn = aws_iam_policy.scheduler_policy[0].arn
}

resource "aws_scheduler_schedule" "weekend_start" {
  count       = var.weekend_scaling_enabled ? 1 : 0
  name        = "${var.project_name}-${var.environment}-weekend-start"
  description = "Scale up ASG for weekend"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(7 days)"
  start_date          = var.weekend_start_time

  target {
    arn      = aws_lambda_function.weekend_scaling[0].arn
    role_arn = aws_iam_role.scheduler_role[0].arn
    input    = jsonencode({ "action" : "scale_up" })
  }
}

resource "aws_scheduler_schedule" "weekend_end" {
  count       = var.weekend_scaling_enabled ? 1 : 0
  name        = "${var.project_name}-${var.environment}-weekend-end"
  description = "Restore normal ASG capacity after weekend"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(7 days)"
  start_date          = var.weekend_end_time

  target {
    arn      = aws_lambda_function.weekend_scaling[0].arn
    role_arn = aws_iam_role.scheduler_role[0].arn
    input    = jsonencode({ "action" : "scale_down" })
  }
}
