output "bucket_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.this.name}"
}

output "bucket_name" {
  value = google_storage_bucket.this.name
}
