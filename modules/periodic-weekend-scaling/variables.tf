
variable "project_name" { type = string }
variable "environment" { type = string }
variable "weekend_scaling_enabled" { type = bool }
variable "asg_name" { type = string }
variable "weekend_min_size" { type = number }
variable "weekend_desired_capacity" { type = number }
variable "weekend_max_size" { type = number }
variable "normal_min_size" { type = number }
variable "normal_desired_capacity" { type = number }
variable "normal_max_size" { type = number }
variable "weekend_start_time" { type = string }
variable "weekend_end_time" { type = string }
variable "tags" { type = map(string) }
