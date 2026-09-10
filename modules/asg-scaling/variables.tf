
variable "project_name" { type = string }
variable "environment" { type = string }
variable "private_app_subnet_ids" { type = list(string) }
variable "asg_min_size" { type = number }
variable "asg_desired_capacity" { type = number }
variable "asg_max_size" { type = number }
variable "target_group_arn" { type = string }
variable "launch_template_id" { type = string }
variable "cpu_target_value" { type = number }
variable "instance_warmup_seconds" { type = number }
variable "tags" { type = map(string) }
