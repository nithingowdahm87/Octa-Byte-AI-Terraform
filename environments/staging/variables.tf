variable "aws_region" { default = "ap-south-1" }
variable "project_name" { default = "octabyte-nithin" }
variable "environment" { default = "staging" }
variable "instance_type" { default = "m7i-flex.large" }
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

variable "ecr_repository_name" {
  type    = string
  default = "octabyte-nithin"
}

variable "key_name" {
  description = "Optional EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}
