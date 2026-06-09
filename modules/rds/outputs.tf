output "db_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "Name of the Gitea database"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Master username for the database"
  value       = aws_db_instance.main.username
}