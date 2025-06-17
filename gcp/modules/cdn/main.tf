# 1. Backend Bucket (예: GCS 정적 버킷에 연결)
resource "google_compute_backend_bucket" "cdn_bucket" {
  name        = var.backend_bucket_name
  bucket_name = var.gcs_bucket_name
  enable_cdn  = true
}

# 2. URL Map
resource "google_compute_url_map" "cdn_url_map" {
  name            = "${var.name_prefix}-url-map"
  default_service = google_compute_backend_bucket.cdn_bucket.self_link
}

# 3. Target HTTP Proxy
resource "google_compute_target_http_proxy" "cdn_proxy" {
  name    = "${var.name_prefix}-proxy"
  url_map = google_compute_url_map.cdn_url_map.self_link
}

# 4. Global Forwarding Rule (HTTP 포트 80)
resource "google_compute_global_forwarding_rule" "cdn_forwarding_rule" {
  name       = "${var.name_prefix}-forwarding-rule"
  port_range = "80"
  target     = google_compute_target_http_proxy.cdn_proxy.self_link
  ip_address = google_compute_global_address.cdn_ip.address
}

# 5. Global Static IP
resource "google_compute_global_address" "cdn_ip" {
  name = "${var.name_prefix}-ip"
}
