
variable "project_name" { type = string }
variable "environment" { type = string }
variable "enable_key_rotation" { type = bool }
variable "delete_wait_days" { type = number }
variable "tags" { type = map(string) }
