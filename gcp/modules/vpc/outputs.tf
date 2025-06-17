output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnet_self_links" {
  value = [for subnet in google_compute_subnetwork.subnetworks : subnet.self_link]
}