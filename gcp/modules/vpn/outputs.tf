output "vpn_static_ip_address" {
  description = "GCP VPN 터널에 사용된 외부 IP (온프레미스에서 대상 IP로 설정)"
  value       = google_compute_address.vpn_static_ip.address
}

output "vpn_gateway_name" {
  description = "생성된 GCP VPN 게이트웨이 이름"
  value       = google_compute_vpn_gateway.vpn_gateway.name
}

output "vpn_tunnel_name" {
  description = "VPN 터널 리소스 이름"
  value       = google_compute_vpn_tunnel.vpn_tunnel.name
}

output "vpn_tunnel_peer_ip" {
  description = "VPN 터널 대상의 Peer IP (온프레미스 공인 IP)"
  value       = google_compute_vpn_tunnel.vpn_tunnel.peer_ip
}

output "vpn_route_name" {
  description = "온프레미스 CIDR로 향하는 라우트 이름"
  value       = google_compute_route.on_prem_route.name
}
