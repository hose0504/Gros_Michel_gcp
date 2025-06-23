variable "bucket_name" {
  description = "GCS 버킷 이름"
}

variable "domain_name" {
  description = "도메인 (예: example.com)"
}

variable "name_prefix" {
  default = "cdn"
}
