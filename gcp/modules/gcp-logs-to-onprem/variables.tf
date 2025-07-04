variable "project_id" {}
variable "region" {
  default = "us-central1"
}
variable "function_zip_path" {
  description = "로컬의 함수 ZIP 경로"
  default     = "../function-source.zip"
}
variable "onprem_api_url" {
  description = "온프레미스 수신 API 주소"
}
variable "pubsub_sa_email" {
  description = "Pub/Sub 메시지를 트리거할 서비스 계정 이메일"
}
