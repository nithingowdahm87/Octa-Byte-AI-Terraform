
variable "create_ecr_repository" { type = bool }
variable "ecr_repository_name" { type = string }
variable "ecr_image_tag" { type = string }
variable "ecr_image_tag_mutability" { type = string }
variable "ecr_scan_on_push" { type = bool }
variable "ecr_force_delete" { type = bool }
variable "ecr_kms_key_arn" { type = string }
variable "tags" { type = map(string) }
