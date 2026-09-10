output "vpc_id" {
  value = module.vpc.vpc_id
}
output "github_deploy_role_arn" {
  value = module.github-oidc.github_actions_role_arn
}
