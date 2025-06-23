provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. VPN용 고정 외부 IP 주소
resource "google_compute_address" "vpn_static_ip" {
  name   = "vpn-static-ip"
  region = var.region
}

# 2. GCP VPN Gateway (Classic)
resource "google_compute_vpn_gateway" "vpn_gateway" {
  name    = "gcp-vpn-gateway"
  network = var.network
  region  = var.region

  depends_on = [google_compute_address.vpn_static_ip]
}

# 3. VPN 터널 (정적 라우팅 기반, IKEv2, Pre-shared key 사용)
resource "google_compute_vpn_tunnel" "vpn_tunnel" {
  name               = "onprem-vpn-tunnel"
  region             = var.region
  target_vpn_gateway = google_compute_vpn_gateway.vpn_gateway.id
  peer_ip            = var.on_prem_public_ip
  shared_secret      = var.shared_secret
  ike_version        = 2

  local_traffic_selector  = [var.gcp_cidr_block]
  remote_traffic_selector = [var.on_prem_cidr_block]

  depends_on = [google_compute_vpn_gateway.vpn_gateway]
}

# 4. GCP → 온프레미스 트래픽용 정적 라우트
resource "google_compute_route" "on_prem_route" {
  name                = "route-to-onprem"
  network             = var.network
  dest_range          = var.on_prem_cidr_block
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.vpn_tunnel.id
}
