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