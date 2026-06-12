variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "eks-gitea"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.35"
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small"
}

variable "min_nodes" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_nodes" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "eks-gitea"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the GitHub Actions role"
  type        = string
  default     = "almahozi/eks-gitea-app"
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
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

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}