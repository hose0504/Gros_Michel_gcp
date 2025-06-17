# GCP 프로젝트 정보
project_id = "skillful-cortex-463200-a7"
region     = "us-central1"
zone       = "us-central1-a"

# VPC 네트워크 설정
network_name = "my-vpc-network"

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

# IAM 설정
service_accounts = [
  {
    name  = "sa-admin-001"
    roles = ["roles/viewer"]
  }
]

roles = [
  "roles/compute.admin",
  "roles/container.admin"
]

# GKE 클러스터 설정
cluster_name    = "gros-michel-gke-cluster"
cluster_version = "1.32.4-gke.1353003"

node_pools = [
  {
    name         = "default-pool"
    machine_type = "e2-medium"
    node_count   = 3
    disk_size_gb = 30            # 💡 줄이기
    disk_type    = "pd-standard" # 💡 HDD로 변경 (쿼터 안 씀)
  }
]

# credentials는 GitHub Actions에서 secrets로 전달되므로 생략
# gcp_credentials = ""
