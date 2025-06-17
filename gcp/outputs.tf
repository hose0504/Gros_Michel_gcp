#--------------------------------------------------
# VPC 모듈에서 내보내는 값들
#--------------------------------------------------
output "vpc_network_name" {
  description = "생성된 VPC 네트워크 이름"
  value       = module.vpc.network_name
}

output "vpc_subnet_self_links" {
  description = "생성된 서브넷들의 self_link 리스트"
  value       = module.vpc.subnet_self_links
}

#--------------------------------------------------
# GKE 모듈에서 내보내는 값들
#--------------------------------------------------
output "gke_cluster_name" {
  description = "생성된 GKE 클러스터 이름"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "GKE API 서버 엔드포인트 (외부 IP)"
  value       = module.gke.endpoint
}

output "gke_cluster_ca_certificate" {
  description = "GKE 클러스터의 CA 인증서 (base64 인코딩)"
  value       = module.gke.ca_certificate
}

#--------------------------------------------------
# (선택) 추가로 보여주고 싶은 값들
#--------------------------------------------------
output "project_id" {
  description = "사용 중인 GCP 프로젝트 ID"
  value       = var.project_id
}

output "region" {
  description = "사용 중인 GCP 리전"
  value       = var.region
}
