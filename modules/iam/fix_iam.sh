sed -i 's/variable "secrets_arn" { type = string }/variable "secrets_arn" { type = string\n  default = "" }/g' variables.tf
sed -i 's/variable "kms_key_arn" { type = string }/variable "kms_key_arn" { type = string\n  default = "" }/g' variables.tf
