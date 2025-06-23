resource "google_storage_bucket" "cdn_bucket" {
  name          = var.bucket_name
  location      = "US"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_compute_backend_bucket" "cdn_backend" {
  name        = "${var.name_prefix}-backend-bucket"
  bucket_name = google_storage_bucket.cdn_bucket.name
  enable_cdn  = true
}

resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "${var.name_prefix}-cert"

  managed {
    domains = [var.domain_name]
  }
}

resource "google_compute_url_map" "url_map" {
  name            = "${var.name_prefix}-url-map"
  default_service = google_compute_backend_bucket.cdn_backend.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "${var.name_prefix}-https-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.id]
}

resource "google_compute_global_address" "lb_ip" {
  name = "${var.name_prefix}-ip"
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name                  = "${var.name_prefix}-https-forwarding-rule"
  target                = google_compute_target_https_proxy.https_proxy.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
}
