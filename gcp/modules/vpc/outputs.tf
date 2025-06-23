output "network_name" {
  description = "VPC 네트워크 이름"
  value       = google_compute_network.main_vpc.name
}

output "subnet_self_links" {
  description = "서브넷 self_link 리스트"
  value       = [for subnet in google_compute_subnetwork.subnets : subnet.self_link]
}
