# GCP 프로젝트 정보
project_id = "skillful-cortex-463200-a7"
region     = "us-central1"
zone       = "us-central1-a"

# VPC 네트워크 설정
network_name = "gros-michel-network"

subnets = [
  {
    name          = "subnet-1"
    ip_cidr_range = "10.0.1.0/24"
    region        = "us-central1"
  },
  {
    name          = "subnet-2"
    ip_cidr_range = "10.0.2.0/24"
    region        = "us-central1"
  }
]

# IAM 서비스 계정
service_accounts = [
  {
    name  = "sa-admin-001"
    roles = ["roles/viewer"]
  }
]

# 프로젝트 수준 역할 바인딩
roles = [
  "roles/compute.admin",
  "roles/container.admin"
]

# GKE 클러스터 설정
cluster_name    = "gros-michel-gke-cluster"
cluster_version = "1.31.9-gke.1005000"

node_pools = [
  {
    name         = "default-pool"
    machine_type = "e2-medium"
    node_count   = 2
    disk_size_gb = 50
    disk_type    = "pd-ssd"
  }
]

# VM 인스턴스 설정
instance_name     = "gros-michel-instance"
machine_type      = "e2-medium"
boot_image        = "ubuntu-os-cloud/ubuntu-2204-lts"
boot_disk_size_gb = 10
boot_disk_type    = "pd-balanced"
network           = "default"
ssh_username      = "wish"
