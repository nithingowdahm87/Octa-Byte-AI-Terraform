
variable "project_name" { type = string }
variable "environment" { type = string }
variable "db_password_rotation_enabled" { type = bool }
variable "db_username_rotation_enabled" { type = bool }
variable "rotation_role_arn" { type = string }
variable "private_app_subnet_ids" { type = list(string) }
variable "rotation_lambda_sg_id" { type = string }
