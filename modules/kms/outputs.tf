output "rds_kms_key_arn" { value = aws_kms_key.keys["rds"].arn }
output "ebs_kms_key_arn" { value = aws_kms_key.keys["ebs"].arn }
