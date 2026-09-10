
output "ecr_repository_url" { value = var.create_ecr_repository ? aws_ecr_repository.app[0].repository_url : "" }
output "ecr_repository_arn" { value = var.create_ecr_repository ? aws_ecr_repository.app[0].arn : "" }
