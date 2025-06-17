# GCP 프로젝트 정보
project_id = "skillful-cortex-463200-a7"
region     = "asia-northeast3"
zone       = "asia-northeast3-a"

# VPC 네트워크 설정
network_name = "my-vpc-network"

subnets = [
  {
    name          = "subnet-1"
    ip_cidr_range = "10.0.1.0/24"
    region        = "asia-northeast3"
  },
  {
    name          = "subnet-2"
    ip_cidr_range = "10.0.2.0/24"
    region        = "asia-northeast3"
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
cluster_name = "gros-michel-gke-cluster"
cluster_version = "1.32.4-gke.1353003"


node_pools = [
  {
    name         = "default-pool"
    machine_type = "e2-medium"
    node_count   = 3
  }
]

# credentials는 GitHub Actions에서 secrets로 전달되므로 비워두거나 생략 가능
# gcp_credentials = "" 
