output "cdn_ip" {
  description = "CDN용 글로벌 IP 주소"
  value       = google_compute_global_address.cdn_ip.address
}

output "cdn_url_map" {
  description = "URL 맵 이름"
  value       = google_compute_url_map.cdn_url_map.name
}
