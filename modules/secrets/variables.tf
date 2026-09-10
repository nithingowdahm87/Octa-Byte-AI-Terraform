
variable "project_name" { 
  type = string
}
variable "environment" { 
  type = string
}
variable "secrets_kms_key_arn" { 
  type = string
  default = ""
}
variable "ssm_kms_key_arn" { 
  type = string
  default = ""
}
variable "db_endpoint" { 
  type = string
  default = "dummy"
}
variable "db_port" { 
  type = number
  default = 5432
}
variable "db_name" { 
  type = string
  default = "appdb"
}
variable "db_master_username" { 
  type = string
  default = "dummy"
}
variable "db_username_parameter_name" { 
  type = string
  default = "db-user"
}
variable "db_username_prefix" { 
  type = string
  default = "user-"
}
variable "tags" { 
  type = map(string)
}
