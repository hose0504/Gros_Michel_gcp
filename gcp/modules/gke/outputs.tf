################################################################################
# modules/gke/outputs.tf
#
# GKE 모듈에서 내보내는 출력값 예시
################################################################################

# GKE 클러스터 이름
output "cluster_name" {
  description = "GKE 클러스터 이름"
  value       = google_container_cluster.primary.name
}

# GKE API 서버 엔드포인트 (외부 IP)
output "endpoint" {
  description = "GKE API 서버 엔드포인트"
  value       = google_container_cluster.primary.endpoint
}

# GKE 클러스터의 CA 인증서 (base64 인코딩)
output "ca_certificate" {
  description = "GKE 클러스터 CA 인증서 (base64 인코딩)"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

# (선택) 노드풀 이름 리스트
# output "node_pool_names" {
#   description = "생성된 노드풀 이름들"
#   value       = [for np in google_container_node_pool.node_pools : np.name]
# }

# (선택) 필요한 경우 kubeconfig 정보를 로컬에 작성할 때 사용할 데이터
# output "cluster_location" {
#   description = "GKE 클러스터 위치"
#   value       = google_container_cluster.primary.location
# }
################################################################################
