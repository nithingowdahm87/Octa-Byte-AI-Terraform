sed -i 's/variable "db_endpoint" { type = string }/variable "db_endpoint" { type = string\n  default = "dummy-endpoint" }/g' variables.tf
sed -i 's/variable "db_port" { type = number }/variable "db_port" { type = number\n  default = 5432 }/g' variables.tf
sed -i 's/variable "db_name" { type = string }/variable "db_name" { type = string\n  default = "appdb" }/g' variables.tf
sed -i 's/variable "db_master_username" { type = string }/variable "db_master_username" { type = string\n  default = "appadmin" }/g' variables.tf
sed -i 's/variable "secrets_kms_key_arn" { type = string }/variable "secrets_kms_key_arn" { type = string\n  default = "" }/g' variables.tf
sed -i 's/variable "ssm_kms_key_arn" { type = string }/variable "ssm_kms_key_arn" { type = string\n  default = "" }/g' variables.tf
sed -i 's/variable "db_username_parameter_name" { type = string }/variable "db_username_parameter_name" { type = string\n  default = "db-user" }/g' variables.tf
sed -i 's/variable "db_username_prefix" { type = string }/variable "db_username_prefix" { type = string\n  default = "user-" }/g' variables.tf
