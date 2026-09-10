
variable "project_name" { 
  type = string
}
variable "environment" { 
  type = string
}
variable "vpc_id" { 
  type = string
}
variable "application_port" { 
  type = number
  default = 8000
}
variable "enable_https" { 
  type = bool
  default = false
}
variable "create_bastion_host" { 
  type = bool
  default = false
}
variable "enable_bastion_ssh" { 
  type = bool
  default = false
}
variable "allowed_admin_cidrs" { 
  type = list(string)
  default = []
}
variable "tags" { 
  type = map(string)
}
