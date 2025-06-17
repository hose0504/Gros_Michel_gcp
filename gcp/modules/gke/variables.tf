################################################################################
# modules/gke/variables.tf
#
# Variables for the GKE module
################################################################################

# GCP 프로젝트 ID
variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

# GCP 리전 (예: us-central1, asia-northeast3 등)
variable "region" {
  description = "GCP 리전"
  type        = string
}

# GKE 클러스터 이름
variable "cluster_name" {
  description = "생성할 GKE 클러스터 이름"
  type        = string
}

# GKE 버전 (예: "1.24.10-gke.1000")
variable "cluster_version" {
  description = "GKE 클러스터 버전"
  type        = string
}

# VPC 네트워크 이름 (module.vpc 출력값)
variable "network" {
  description = "클러스터가 연결될 VPC 네트워크 이름 또는 self_link"
  type        = string
}

# VPC 서브네트워크 self_link (module.vpc 출력값)
variable "subnetwork" {
  description = "클러스터가 연결될 VPC 서브네트워크 self_link"
  type        = string
}

# 노드풀 설정 리스트
variable "node_pools" {
  description = "생성할 GKE 노드풀 설정 리스트"
  type = list(object({
    name         = string # 노드풀 이름
    machine_type = string # 머신 타입 (예: "e2-medium")
    node_count   = number # 초기 노드 수
  }))
}

# (선택) kubeconfig 생성 시 사용할 서비스 계정 키 경로
variable "credentials_file_path" {
  description = "kubeconfig 생성 시 사용할 서비스 계정 키(JSON) 파일 경로"
  type        = string
  default     = ""
}
