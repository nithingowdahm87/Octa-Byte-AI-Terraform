output "github_actions_role_arn" {
  value = length(aws_iam_role.github_actions) > 0 ? aws_iam_role.github_actions[0].arn : ""
}
