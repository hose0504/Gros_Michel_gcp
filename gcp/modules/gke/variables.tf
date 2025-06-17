################################################################################
# modules/gke/variables.tf
# GKE 모듈에서 사용하는 변수 정의
################################################################################

# GCP 프로젝트 ID
variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

# GCP 리전
variable "region" {
  description = "GCP 리전 (예: us-central1, asia-northeast3 등)"
  type        = string
}

# GKE 클러스터 이름
variable "cluster_name" {
  description = "생성할 GKE 클러스터 이름"
  type        = string
}

# GKE 클러스터 버전
variable "cluster_version" {
  description = "GKE 클러스터 버전 (예: 1.24.10-gke.1000)"
  type        = string
}

# VPC 네트워크 이름 또는 self_link
variable "network" {
  description = "클러스터가 연결될 VPC 네트워크 이름 또는 self_link"
  type        = string
}

# VPC 서브네트워크 self_link
variable "subnetwork" {
  description = "클러스터가 연결될 VPC 서브네트워크 self_link"
  type        = string
}

# GKE 노드풀 설정 리스트
variable "node_pools" {
  description = "생성할 GKE 노드풀 설정 리스트"
  type = list(object({
    name         = string
    machine_type = string
    node_count   = number
  }))
}

# 로컬에서 kubeconfig 생성 시 사용할 서비스 계정 키 경로 (CI에서는 사용하지 않음)
variable "credentials_file_path" {
  description = "로컬에서 kubeconfig 생성 시 사용할 서비스 계정 키(JSON) 경로"
  type        = string
  default     = ""
}
