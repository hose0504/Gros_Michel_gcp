# ─────────────────────────────────────────────
# 🔥 GCP Firewall Rules for HTTP and HTTPS
# - Opens port 80 (HTTP) and 443 (HTTPS) to all IPs
# - Applies to GKE node instances via network tags
# - Required for external traffic to reach Ingress / NodePort
# ─────────────────────────────────────────────

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "gros-michel-network"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  direction     = "INGRESS"
  priority      = 1000
  target_tags   = ["gke-gros-michel-gke-cluster-baafdfc1-node"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = "gros-michel-network"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  direction     = "INGRESS"
  priority      = 1000
  target_tags   = ["gke-gros-michel-gke-cluster-baafdfc1-node"]
  source_ranges = ["0.0.0.0/0"]
}
