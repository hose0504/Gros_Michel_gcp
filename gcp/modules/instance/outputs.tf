output "instance_name" {
  description = "생성된 인스턴스 이름"
  value       = google_compute_instance.vm_instance.name
}

output "external_ip" {
  description = "VM 외부 IP 주소"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
