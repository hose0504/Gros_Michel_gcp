################################################################################
# modules/gke/main.tf
# GKE 클러스터와 노드풀을 정의하는 모듈의 메인 파일 (수정 완료 버전)
################################################################################

#-------------------------------
# GKE 클러스터 생성
#-------------------------------
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  min_master_version = var.cluster_version

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }

  lifecycle {
    ignore_changes = [master_auth]
  }
}

#-------------------------------
# GKE 노드풀 생성
#-------------------------------
resource "google_container_node_pool" "node_pools" {
  for_each = { for np in var.node_pools : np.name => np }

  name     = each.value.name
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

node_config {
  machine_type = each.value.machine_type
  oauth_scopes = [
    "https://www.googleapis.com/auth/cloud-platform"
  ]
  metadata = {
    disable-legacy-endpoints = "true"
  }
  image_type = "COS_CONTAINERD"
}


  initial_node_count = each.value.node_count

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}

#-------------------------------
# 클러스터 정보 조회
#-------------------------------
data "google_container_cluster" "cluster_info" {
  name     = google_container_cluster.primary.name
  location = google_container_cluster.primary.location
  project  = var.project_id
}

data "google_client_config" "current" {}

#-------------------------------
# kubeconfig 생성
#-------------------------------
resource "local_file" "kubeconfig" {
  count = var.credentials_file_path != "" ? 1 : 0 # 로컬에서만 실행

  content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name     = data.google_container_cluster.cluster_info.name
    cluster_endpoint = data.google_container_cluster.cluster_info.endpoint
    cluster_ca_cert  = base64decode(data.google_container_cluster.cluster_info.master_auth[0].cluster_ca_certificate)
    client_cert      = ""
    client_key       = ""
    token            = ""
    project          = var.project_id
    region           = var.region
    user             = "terraform"
    credentials_json = file(var.credentials_file_path)
  })

  filename = "${path.module}/generated_kubeconfig"
}

# gcp/main.tf (루트 디렉토리)

# ... 다른 리소스 및 모듈 정의 ...

# 고정 IP 주소 참조 (이미 존재하는 IP)
# GKE 모듈 밖, 루트 레벨에서 직접 참조
data "google_compute_address" "ingress_static_ip_data" { # 이름 변경 (기존 모듈 이름과 충돌 방지)
  name    = "grosmichel-ip"  # GCP 콘솔에 있는 고정 IP 이름
  region  = var.region
  project = var.project_id
}

# 고정 IP 이름 출력 (루트 레벨에서 직접 출력)
output "ingress_ip_name" {
  description = "The name of the existing static IP for Ingress."
  value       = data.google_compute_address.ingress_static_ip_data.name
}