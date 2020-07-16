output "address" {
  value       = aws_db_instance.demo_db_instance_1.address
  description = "Connect to the database at this endpoint"
}

output "port" {
  value       = aws_db_instance.demo_db_instance_1.port
  description = "The port the database is listening on"
}
