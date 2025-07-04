resource "google_dns_managed_zone" "grosmichelus" {
  name        = "grosmichelus-zone"
  dns_name    = "grosmichelus.com."
  description = "Terraform-managed DNS zone"

  dnssec_config {
    state = "off"
  }
}
