
output "alb_sg_id" { value = aws_security_group.alb.id }
output "app_sg_id" { value = aws_security_group.app.id }
output "rds_sg_id" { value = aws_security_group.rds.id }
output "rotation_lambda_sg_id" { value = aws_security_group.rotation_lambda.id }
output "vpc_endpoints_sg_id" { value = aws_security_group.vpc_endpoints.id }
output "bastion_sg_id" { value = var.create_bastion_host ? aws_security_group.bastion[0].id : null }
