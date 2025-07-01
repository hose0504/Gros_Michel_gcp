#-------------------------------
# GKE 노드풀 생성
#-------------------------------
resource "google_container_node_pool" "node_pools" {
  for_each = { for np in var.node_pools : np.name => np }

  name     = each.value.name
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.primary.name

  # 노드 개수
  initial_node_count = each.value.node_count

  # 노드 구성
  node_config {
    machine_type = each.value.machine_type        # 머신 타입 (예: e2-medium)
    image_type   = "COS_CONTAINERD"                # 컨테이너 최적화 이미지

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  # 자동 업그레이드 설정
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}
