variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전 (예: us-central1)"
  type        = string
}

variable "network" {
  description = "VPN을 연결할 VPC 네트워크 이름"
  type        = string
}

variable "on_prem_public_ip" {
  description = "온프레미스 측 VPN 장비의 공인 IP 주소"
  type        = string
}

variable "on_prem_cidr_block" {
  description = "온프레미스 내부 네트워크 CIDR (예: 10.1.0.0/16)"
  type        = string
}

variable "gcp_cidr_block" {
  description = "GCP 측 VPC CIDR (예: 10.2.0.0/16)"
  type        = string
}

variable "shared_secret" {
  description = "VPN 터널에 사용할 Pre-Shared Key (PSK)"
  type        = string
  sensitive   = true
}
