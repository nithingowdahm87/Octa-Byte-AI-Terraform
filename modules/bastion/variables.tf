
variable "project_name" { type = string }
variable "environment" { type = string }
variable "create_bastion_host" { type = bool }
variable "bastion_instance_type" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "bastion_sg_id" { type = string }
variable "tags" { type = map(string) }
