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
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  tags               = local.tags
}