variable "project_name" { type = string }
variable "environment" { type = string }
variable "alb_arn_suffix" { type = string }
variable "max_5xx_count_per_minute" { 
  type = number
  default = 5
}
variable "max_target_response_time_seconds" { 
  type = number
  default = 1.5
}
