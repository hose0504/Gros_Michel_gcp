# GCP 인증 키 파일
gcp_credentials = file("gcp-key.json")  # 로컬에서 사용할 서비스 계정 키 경로

# GCP 프로젝트 정보
project_id = "my-gcp-project"
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
    name  = "sa-1"
    roles = ["roles/viewer"]
  }
]

roles = [
  "roles/compute.admin",
  "roles/container.admin"
]

# GKE 클러스터 설정
cluster_name    = "my-gke-cluster"
cluster_version = "1.24.10-gke.1000"

node_pools = [
  {
    name         = "default-pool"
    machine_type = "e2-medium"
    node_count   = 3
  }
]
