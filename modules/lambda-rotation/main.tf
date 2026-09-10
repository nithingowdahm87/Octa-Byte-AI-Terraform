
resource "aws_lambda_function" "pwd_rotation" {
  count         = var.db_password_rotation_enabled ? 1 : 0
  filename      = "${path.root}/../../lambda/db-password-rotation.zip"
  function_name = "${var.project_name}-${var.environment}-pwd-rot"
  role          = var.rotation_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  vpc_config {
    subnet_ids         = var.private_app_subnet_ids
    security_group_ids = [var.rotation_lambda_sg_id]
  }
}
