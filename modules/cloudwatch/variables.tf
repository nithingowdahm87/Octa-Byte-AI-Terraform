
variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "log_retention_days" { type = number }
variable "enable_log_kms_encryption" { type = bool }
variable "logs_kms_key_arn" { type = string }
variable "create_alarm_sns_topic" { type = bool }
variable "alarm_email" { type = string }
variable "alb_arn" { type = string }
variable "asg_name" { type = string }
variable "db_identifier" { type = string }
variable "tags" { type = map(string) }
