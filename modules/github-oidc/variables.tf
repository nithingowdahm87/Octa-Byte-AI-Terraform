
variable "project_name" { type = string }
variable "environment" { type = string }
variable "create_github_oidc_role" { type = bool }
variable "github_org" { type = string }
variable "github_repository" { type = string }
variable "github_branch" { type = string }
variable "github_environment" { type = string }
variable "create_oidc_provider" {
  type = bool
  default = false
}
