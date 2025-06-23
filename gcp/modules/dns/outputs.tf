output "name_servers" {
  description = "DNS NS 레코드 목록"
  value       = google_dns_managed_zone.this.name_servers
}

output "zone_name" {
  description = "생성된 Zone 이름"
  value       = google_dns_managed_zone.this.name
}
