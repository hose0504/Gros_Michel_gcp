variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "network_name" {
  description = "VPC 네트워크 이름"
  type        = string
}

variable "subnets" {
  description = "생성할 서브넷 리스트"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
  }))
}

variable "gcp_credentials" {
  description = "GCP 서비스 계정 키 (JSON 문자열)"
  type        = string
}
