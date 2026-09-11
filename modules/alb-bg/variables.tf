variable "project_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "alb_sg_id" { type = string }
variable "application_port" { type = number }
variable "health_check_path" { type = string }
variable "alb_enable_deletion_protection" { type = bool }
variable "enable_https" { type = bool }
variable "acm_certificate_arn" { type = string }
variable "tags" { type = map(string) }

variable "blue_weight" {
  type    = number
  default = 100
}

variable "green_weight" {
  type    = number
  default = 0
}
