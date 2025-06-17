variable "zone_name" {
  description = "Cloud DNS Zone 이름"
  type        = string
}

variable "dns_name" {
  description = "도메인 이름 (예: example.com.)"
  type        = string
}

variable "description" {
  description = "Zone 설명"
  type        = string
  default     = "Managed by Terraform"
}

variable "record_name" {
  description = "레코드 이름 (예: www)"
  type        = string
}

variable "a_record_ip" {
  description = "A 레코드 대상 IP 주소"
  type        = string
}
