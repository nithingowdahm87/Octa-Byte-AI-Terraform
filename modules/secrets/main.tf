
resource "random_password" "db_password" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name       = "${var.project_name}/${var.environment}/database/admin"
  kms_key_id = var.secrets_kms_key_arn

  tags = merge(var.tags, { Name = "${var.project_name}/${var.environment}/database/admin" })
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = var.db_endpoint
    port     = var.db_port
    dbname   = var.db_name
    username = var.db_master_username
    password = random_password.db_password.result
  })
}

resource "random_password" "db_username_suffix" {
  length  = 8
  special = false
}

resource "aws_ssm_parameter" "db_username" {
  name   = var.db_username_parameter_name
  type   = "SecureString"
  value  = "${var.db_username_prefix}_${random_password.db_username_suffix.result}"
  key_id = var.ssm_kms_key_arn

  tags = merge(var.tags, { Name = var.db_username_parameter_name })
}
