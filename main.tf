provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "deip-terraform-states"
    key     = "template/terraform.tfstate"
    encrypt = true
    region = "eu-central-1"
  }
}

module "label" {
  source = "cloudposse/label/null"
  version  = "0.25.0"
  namespace  = "deip"
  environment = "portal"
  name       = var.portal
  delimiter  = "-"
  attributes = ["cluster"]
  tags = var.tags
}



locals {
  # Prior to Kubernetes 1.19, the usage of the specific kubernetes.io/cluster/* resource tags below are required
  # for EKS and Kubernetes to discover and manage networking resources
  # https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html#base-vpc-networking
  tags = { "kubernetes.io/cluster/${module.label.id}" = "shared" }
}

module "vpc" {
  source = "cloudposse/vpc/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version     = "0.28.1"
  cidr_block = "172.16.0.0/16"

  tags    = local.tags
  context = module.label.context
}

module "subnets" {
  source = "cloudposse/dynamic-subnets/aws"
  # Cloud Posse recommends pinning every module to a specific version
   version     = "0.39.8"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  tags    = local.tags
  context = module.label.context
}

module "eks_node_group" {
  source = "cloudposse/eks-node-group/aws"
  # Cloud Posse recommends pinning every module to a specific version
   version     = "0.27.3"

  instance_types                     = [var.instance_type]
  subnet_ids                         = module.subnets.public_subnet_ids
#  health_check_type                  = var.health_check_type
  min_size                           = var.min_size
  max_size                           = var.max_size
  desired_size                       = var.desired_size
  cluster_name                       = module.eks_cluster.eks_cluster_id

  # Enable the Kubernetes cluster auto-scaler to find the auto-scaling group
  cluster_autoscaler_enabled = false

  context = module.label.context

  # Ensure the cluster is fully created before trying to add the node group
  module_depends_on = module.eks_cluster.kubernetes_config_map_id
}

module "eks_cluster" {
  source = "cloudposse/eks-cluster/aws"
  region = var.region
  # Cloud Posse recommends pinning every module to a specific version
  version = "0.45.0"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.subnets.public_subnet_ids

  kubernetes_version    = var.kubernetes_version
  oidc_provider_enabled = true

  context = module.label.context
}

resource "aws_ecr_repository" "backend_repository" {
  name                 =  "${var.portal}-backend"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend_repository" {
  name                 = "${var.portal}-frontend"

  image_scanning_configuration {
    scan_on_push = true
  }
}