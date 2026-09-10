
variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_app_subnet_ids" { type = list(string) }
variable "private_db_subnet_ids" { type = list(string) }
variable "application_port" { type = number }
variable "tags" { type = map(string) }
