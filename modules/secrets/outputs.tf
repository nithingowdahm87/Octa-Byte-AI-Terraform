
output "rds_master_password" {
  value     = random_password.db_password.result
  sensitive = true
}
output "rds_secret_arn" { value = aws_secretsmanager_secret.db.arn }
output "rds_username_parameter_arn" { value = aws_ssm_parameter.db_username.arn }
