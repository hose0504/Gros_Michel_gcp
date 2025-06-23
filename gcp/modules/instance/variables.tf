variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "boot_image" {
  type = string
}

variable "boot_disk_size_gb" {
  type = number
}

variable "boot_disk_type" {
  type = string
}

variable "network" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "ssh_pub_key" {
  description = "SSH 공개키 문자열"
  type        = string
}

