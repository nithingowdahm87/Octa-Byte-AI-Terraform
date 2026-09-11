
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  keys = ["rds", "secrets", "ssm", "ebs", "logs"]
}

resource "aws_kms_key" "keys" {
  for_each                = toset(local.keys)
  description             = "KMS key for ${each.key} in ${var.project_name}-${var.environment}"
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.delete_wait_days

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-default-1"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      
      {
        Sid    = "Allow use of the key"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
          ,"kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-${each.key}-kms" })
}

resource "aws_kms_alias" "aliases" {
  for_each      = toset(local.keys)
  name          = "alias/${var.project_name}-${var.environment}-${each.key}"
  target_key_id = aws_kms_key.keys[each.key].key_id
}
