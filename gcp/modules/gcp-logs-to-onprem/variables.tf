variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
  default     = "us-central1"
}

variable "function_zip_path" {
  description = "로컬의 함수 ZIP 경로"
  type        = string
  default     = "../function-source.zip"
}

variable "onprem_api_url" {
  description = "온프레미스 수신 API 주소"
  type        = string
}

variable "pubsub_sa_email" {
  description = "Pub/Sub 트리거를 수행할 서비스 계정 이메일"
  type        = string
}
