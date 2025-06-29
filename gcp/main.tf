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
  source          = "./modules/vpc"
  project_id      = var.project_id
  network_name    = var.network_name
  subnets         = var.subnets
  gcp_credentials = var.gcp_credentials
}

#-------------------------------
# IAM 모듈 호출 (선택)
#-------------------------------
module "iam" {
  source           = "./modules/iam"
  project_id       = var.project_id
  service_accounts = var.service_accounts
  roles            = var.roles

  depends_on = [module.gke]
}

#-------------------------------
# GKE 모듈 호출
#-------------------------------
module "gke" {
  source          = "./modules/gke"
  project_id      = var.project_id
  region          = var.region
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  network         = module.vpc.network_name
  subnetwork      = module.vpc.subnet_self_links[0]
  node_pools      = var.node_pools
}


module "instance" {
  source = "./modules/instance"

  project_id        = var.project_id
  region            = var.region # ✅ 추가
  zone              = var.zone
  network           = var.network
  instance_name     = var.instance_name
  machine_type      = var.machine_type
  boot_image        = var.boot_image
  boot_disk_size_gb = var.boot_disk_size_gb
  boot_disk_type    = var.boot_disk_type
  ssh_username      = var.ssh_username
  ssh_pub_key       = var.ssh_pub_key
}

terraform {
  backend "gcs" {
    bucket = "grosmichel-tfstate-202506180252"
    prefix = "terraform/state"
  }
}

module "hlb" {
  source      = "./modules/HLB"
  bucket_name = "gros-michel-cdn-bucket-202506230121"
  domain_name = "grosmichelus.com"
  name_prefix = "gros-cdn"
}
