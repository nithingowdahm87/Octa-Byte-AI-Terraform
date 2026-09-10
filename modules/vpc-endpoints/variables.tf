
variable "project_name" { type = string }
variable "environment" { type = string }
variable "aws_region" { type = string }
variable "vpc_id" { type = string }
variable "private_app_subnet_ids" { type = list(string) }
variable "private_app_route_table_ids" { type = list(string) }
variable "vpc_endpoints_sg_id" { type = string }
variable "tags" { type = map(string) }
