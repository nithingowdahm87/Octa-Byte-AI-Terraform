
variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "application_port" { type = number }
variable "enable_https" { type = bool }
variable "create_bastion_host" { type = bool }
variable "enable_bastion_ssh" { type = bool }
variable "allowed_admin_cidrs" { type = list(string) }
variable "tags" { type = map(string) }
