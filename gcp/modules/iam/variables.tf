variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "service_accounts" {
  description = "생성할 서비스 계정 리스트 및 역할"
  type = list(object({
    name  = string
    roles = list(string)
  }))
}

variable "roles" {
  description = "할당할 IAM 역할 리스트"
  type        = list(string)
}