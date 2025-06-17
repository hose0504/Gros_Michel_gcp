terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

#-------------------------------
# VPC 모듈 호출
#-------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_id   = var.project_id
  network_name = var.network_name
  subnets      = var.subnets
}

#-------------------------------
# IAM 모듈 호출 (필요하면)
#-------------------------------
module "iam" {
  source = "./modules/iam"

  project_id       = var.project_id
  service_accounts = var.service_accounts
  roles            = var.roles
}

#-------------------------------
# GKE 모듈 호출
#-------------------------------
module "gke" {
  source = "./modules/gke"

  project_id      = var.project_id
  region          = var.region
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  network    = module.vpc.network_name
  subnetwork = module.vpc.subnet_self_links[0]

  node_pools = var.node_pools
}
