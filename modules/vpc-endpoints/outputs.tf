
output "ecr_api_vpc_endpoint_id" { value = aws_vpc_endpoint.interface["ecr.api"].id }
output "ecr_dkr_vpc_endpoint_id" { value = aws_vpc_endpoint.interface["ecr.dkr"].id }
output "ssm_vpc_endpoint_ids" { value = aws_vpc_endpoint.interface["ssm"].id }
output "secretsmanager_vpc_endpoint_id" { value = aws_vpc_endpoint.interface["secretsmanager"].id }
