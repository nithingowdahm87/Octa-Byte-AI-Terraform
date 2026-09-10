
output "rds_key_arn" { value = aws_kms_key.keys["rds"].arn }
output "secrets_key_arn" { value = aws_kms_key.keys["secrets"].arn }
output "ssm_key_arn" { value = aws_kms_key.keys["ssm"].arn }
output "ebs_key_arn" { value = aws_kms_key.keys["ebs"].arn }
output "logs_key_arn" { value = aws_kms_key.keys["logs"].arn }
output "rds_kms_key_arn" { value = "arn:aws:kms:region:account:key/1234" }
output "ebs_kms_key_arn" { value = "arn:aws:kms:region:account:key/5678" }
