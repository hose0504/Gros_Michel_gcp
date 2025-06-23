output "bucket_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.cdn_bucket.name}/index.html"
}

output "load_balancer_ip" {
  value = google_compute_global_address.lb_ip.address
}
