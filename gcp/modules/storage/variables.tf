variable "bucket_name" {
  description = "버킷 이름 (전역 유일)"
  type        = string
}

variable "location" {
  description = "버킷 리전 (예: US, ASIA, EU 등)"
  type        = string
  default     = "US"
}

variable "public_access" {
  description = "버킷을 public 읽기 가능하게 할지 여부"
  type        = bool
  default     = false
}

variable "main_page_suffix" {
  description = "정적 웹사이트 호스팅 메인 페이지 (index.html 등)"
  type        = string
  default     = "index.html"
}

variable "not_found_page" {
  description = "404 페이지"
  type        = string
  default     = "404.html"
}
