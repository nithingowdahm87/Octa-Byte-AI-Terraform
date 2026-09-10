
variable "project_name" { type = string }
variable "environment" { type = string }
variable "private_db_subnet_ids" { type = list(string) }
variable "rds_sg_id" { type = string }
variable "rds_kms_key_arn" { type = string }
variable "db_instance_class" { type = string }
variable "db_allocated_storage" { type = number }
variable "db_max_allocated_storage" { type = number }
variable "db_multi_az" { type = bool }
variable "db_name" { type = string }
variable "db_master_username" { type = string }
variable "db_master_password" { type = string }
variable "db_port" { type = number }
variable "db_deletion_protection" { type = bool }
variable "db_skip_final_snapshot" { type = bool }
variable "db_backup_retention_days" { type = number }
variable "tags" { type = map(string) }
