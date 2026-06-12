locals {
  tags = {
    Project     = "eks-gitea"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  tags         = local.tags
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = var.cluster_name
  k8s_version        = var.k8s_version
  instance_type      = var.instance_type
  min_nodes          = var.min_nodes
  desired_nodes      = var.desired_nodes
  max_nodes          = var.max_nodes
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  tags               = local.tags
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.repository_name
  tags            = local.tags
}

module "rds" {
  source                    = "./modules/rds"
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  cluster_name              = var.cluster_name
  cluster_security_group_id = module.eks.cluster_security_group_id
  db_instance_class         = var.db_instance_class
  db_name                   = var.db_name
  db_username               = var.db_username
  db_password               = var.db_password
  tags                      = local.tags
}

# GitHub Actions OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = local.tags
}

# GitHub Actions IAM Role
resource "aws_iam_role" "github_actions" {
  name = "eks-gitea-github-actions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
        }
      }
    }]
  })

  tags = local.tags
}

# ECR Push Policy
resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# IAM Policy for SSM access
resource "aws_iam_policy" "gitea_ssm" {
  name = "eks-gitea-ssm-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = "arn:aws:ssm:eu-central-1:406708888206:parameter/eks-gitea/*"
    }]
  })
}

# IAM Role for Gitea pods (IRSA)
resource "aws_iam_role" "gitea" {
  name = "eks-gitea-pod-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:default:gitea"
          "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "gitea_ssm" {
  role       = aws_iam_role.gitea.name
  policy_arn = aws_iam_policy.gitea_ssm.arn
}

# ALB Controller IAM Policy
resource "aws_iam_policy" "alb_controller" {
  name   = "eks-gitea-alb-controller-policy"
  policy = file("${path.module}/policies/alb-controller-policy.json")
}

# ALB Controller IAM Role (IRSA)
resource "aws_iam_role" "alb_controller" {
  name = "eks-gitea-alb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}