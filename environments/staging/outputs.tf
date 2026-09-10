output "staging_instance_id" {
  value = aws_instance.staging.id
}
output "staging_public_ip" {
  value = aws_instance.staging.public_ip
}
output "staging_public_dns" {
  value = aws_instance.staging.public_dns
}
output "staging_base_url" {
  value = "http://${aws_instance.staging.public_ip}"
}

output "github_deploy_role_arn" {
  value       = module.github-oidc.github_actions_role_arn
  description = "Role ARN for GitHub Actions deployment"
}

output "staging_private_key" {
  value       = tls_private_key.staging_ssh.private_key_pem
  description = "The generated private key for SSH access. Save this to a .pem file locally."
  sensitive   = true
}
