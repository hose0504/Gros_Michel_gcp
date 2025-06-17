# 1. DNS Zone 생성
resource "google_dns_managed_zone" "this" {
  name        = var.zone_name
  dns_name    = var.dns_name
  description = var.description

  visibility = "public"
}

# 2. A 레코드 생성
resource "google_dns_record_set" "a_record" {
  name         = "${var.record_name}.${var.dns_name}"
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.this.name

  rrdatas = [var.a_record_ip]
}
