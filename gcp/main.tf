terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20"
    }
  }

  backend "gcs" {
    bucket = "grosmichel-tfstate-202506180252"
    prefix = "terraform/state"
  }
}

#----------------------------------------
# ✅ VPC (네트워크)
#----------------------------------------
module "vpc" {
  source          = "./modules/vpc"
  project_id      = var.project_id
  network_name    = var.network_name
  subnets         = var.subnets
  gcp_credentials = var.gcp_credentials
}

#----------------------------------------
# ✅ GKE 클러스터
#----------------------------------------
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

#----------------------------------------
# ✅ IAM (서비스 계정 및 권한)
#----------------------------------------
module "iam" {
  source           = "./modules/iam"
  project_id       = var.project_id
  service_accounts = var.service_accounts
  roles            = var.roles

  depends_on = [module.gke]
}

#----------------------------------------
# ✅ Bastion 또는 VM 인스턴스
#----------------------------------------
module "instance" {
  source = "./modules/instance"

  project_id        = var.project_id
  region            = var.region
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

#----------------------------------------
# ✅ HTTPS Load Balancer (정적 콘텐츠 CDN)
#----------------------------------------
module "hlb" {
  source      = "./modules/HLB"
  bucket_name = "gros-michel-cdn-bucket-202506230121"
  domain_name = "grosmichelus.com"
  name_prefix = "gros-cdn"
}

#----------------------------------------
# ✅ GCP Logs → On-Prem 로그 서버
#----------------------------------------
module "gcp_logs_to_onprem" {
  source          = "./modules/gcp-logs-to-onprem"
  project_id      = var.project_id
  region          = var.region
  onprem_api_url  = var.onprem_api_url
  pubsub_sa_email = var.pubsub_sa_email

  depends_on = [module.iam]
}
