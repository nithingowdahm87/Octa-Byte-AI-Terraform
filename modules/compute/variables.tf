
variable "project_name" { type = string }
variable "environment" { type = string }
variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "app_sg_id" { type = string }
variable "ec2_instance_profile_name" { type = string }
variable "root_volume_size" { type = number }
variable "root_volume_type" { type = string }
variable "ebs_kms_key_arn" { type = string }
variable "enable_detailed_monitoring" { type = bool }
variable "user_data" { type = string }
variable "tags" { type = map(string) }
