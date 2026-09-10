output "alb_sg_id" { value = aws_security_group.alb.id }
output "ec2_sg_id" { value = aws_security_group.app.id }
output "rds_sg_id" { value = aws_security_group.rds.id }
output "vpc_endpoints_sg_id" { value = aws_security_group.vpc_endpoints.id }
output "bastion_sg_id" { value = length(aws_security_group.bastion) > 0 ? aws_security_group.bastion[0].id : "" }
