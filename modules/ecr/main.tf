
resource "aws_ecr_repository" "app" {
  count                = var.create_ecr_repository ? 1 : 0
  name                 = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  force_delete         = var.ecr_force_delete

  encryption_configuration {
    encryption_type = var.ecr_kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.ecr_kms_key_arn
  }

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  tags = merge(var.tags, { Name = var.ecr_repository_name })
}

resource "aws_ecr_lifecycle_policy" "app" {
  count      = var.create_ecr_repository ? 1 : 0
  repository = aws_ecr_repository.app[0].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}
