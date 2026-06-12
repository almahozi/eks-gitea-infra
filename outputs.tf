output "db_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_endpoint
}

output "gitea_role_arn" {
  value = aws_iam_role.gitea.arn
}