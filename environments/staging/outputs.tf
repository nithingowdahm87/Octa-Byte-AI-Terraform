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
