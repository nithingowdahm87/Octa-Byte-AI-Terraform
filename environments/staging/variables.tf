variable "aws_region" { default = "ap-south-1" }
variable "project_name" { default = "octabyte-nithin" }
variable "environment" { default = "staging" }
variable "instance_type" { default = "t3.micro" }
variable "staging_subnet_id" { 
  type = string
  default = "" 
}
variable "tags" { default = {
  Project     = "OctaByte-Nithin"
  Environment = "staging"
  Owner       = "nithingowdahm87"
  ManagedBy   = "Terraform"
} }
