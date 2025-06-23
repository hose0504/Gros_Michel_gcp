variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전 (예: asia-northeast3)"
  type        = string
}

variable "zone" {
  description = "GCP 존 (예: asia-northeast3-a)"
  type        = string
}

variable "gcp_credentials" {
  description = "GCP 서비스 계정 키 (JSON 문자열 또는 file(...) 경로)"
  type        = string
}

variable "network_name" {
  description = "VPC 네트워크 이름"
  type        = string
}

variable "subnets" {
  description = "서브넷 리스트"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
  }))
}

variable "service_accounts" {
  description = "생성할 서비스 계정 리스트"
  type = list(object({
    name  = string
    roles = list(string)
  }))
}

variable "roles" {
  description = "할당할 IAM 역할 리스트"
  type        = list(string)
}

variable "cluster_name" {
  description = "GKE 클러스터 이름"
  type        = string
}

variable "cluster_version" {
  description = "GKE 클러스터 버전 (지정하지 않으면 GCP가 자동 선택)"
  type        = string
  default     = null
}

variable "node_pools" {
  description = "노드풀 설정 리스트"
  type = list(object({
    name         = string
    machine_type = string
    node_count   = number
  }))
}

# ---------- VM 인스턴스 관련 ----------
variable "instance_name" {
  description = "VM 인스턴스 이름"
  type        = string
}

variable "machine_type" {
  description = "VM 머신 타입"
  type        = string
}

variable "boot_image" {
  description = "OS 이미지"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "부팅 디스크 크기 (GB)"
  type        = number
}

variable "boot_disk_type" {
  description = "디스크 유형"
  type        = string
}

variable "network" {
  description = "네트워크 이름"
  type        = string
}

variable "ssh_username" {
  description = "SSH 사용자 이름"
  type        = string
}

variable "ssh_pub_key" {
  description = "SSH 공개키 전체 문자열 (e.g. ssh-rsa ...)"
  type        = string
}


