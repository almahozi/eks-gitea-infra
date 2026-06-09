variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for RDS"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

variable "db_name" {
  description = "Name of the Gitea database"
  type        = string
  default     = "gitea"
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  default     = "gitea"
}

variable "db_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}