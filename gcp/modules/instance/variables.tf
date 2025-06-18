variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "zone" {
  description = "GCP 영역"
  type        = string
}

variable "instance_name" {
  description = "VM 인스턴스 이름"
  type        = string
}

variable "machine_type" {
  description = "VM 머신 타입"
  type        = string
}

variable "boot_image" {
  description = "OS 이미지 (예: ubuntu-os-cloud/ubuntu-2404-lts)"
  type        = string
}

variable "boot_disk_size_gb" {
  description = "부팅 디스크 크기 (GB)"
  type        = number
  default     = 10
}

variable "boot_disk_type" {
  description = "디스크 유형"
  type        = string
  default     = "pd-balanced"
}

variable "network" {
  description = "네트워크 이름"
  type        = string
  default     = "default"
}

variable "ssh_username" {
  description = "SSH 사용자 이름"
  type        = string
}

variable "public_key_path" {
  description = "공개키(.pub) 파일 경로"
  type        = string
}
