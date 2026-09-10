
variable "project_name" { type = string }
variable "environment" { type = string }
variable "secrets_kms_key_arn" { type = string }
variable "ssm_kms_key_arn" { type = string }
variable "db_endpoint" { type = string }
variable "db_port" { type = number }
variable "db_name" { type = string }
variable "db_master_username" { type = string }
variable "db_username_parameter_name" { type = string }
variable "db_username_prefix" { type = string }
variable "tags" { type = map(string) }
