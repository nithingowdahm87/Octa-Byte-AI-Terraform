
output "vpc_id" { value = aws_vpc.main.id }
output "availability_zones" { value = local.availability_zones }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_application_subnet_ids" { value = aws_subnet.private_app[*].id }
output "private_database_subnet_ids" { value = aws_subnet.private_db[*].id }
output "private_app_route_table_ids" { value = aws_route_table.private_app[*].id }
output "private_db_subnets" { value = ["subnet-1", "subnet-2"] }
output "public_subnets" { value = ["subnet-3", "subnet-4"] }
output "private_app_subnets" { value = ["subnet-5", "subnet-6"] }
