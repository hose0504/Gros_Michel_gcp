variable "name_prefix" {
  description = "리소스 이름 접두사"
  type        = string
}

variable "backend_bucket_name" {
  description = "백엔드 버킷 리소스 이름 (CDN 대상)"
  type        = string
}

variable "gcs_bucket_name" {
  description = "GCS 버킷 이름 (정적 컨텐츠 제공용)"
  type        = string
}
