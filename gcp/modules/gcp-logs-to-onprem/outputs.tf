output "function_url" {
  value = google_cloudfunctions_function.log_to_onprem.https_trigger_url
}

output "bucket_name" {
  value = google_storage_bucket.log_bucket.name
}

output "pubsub_topic" {
  value = google_pubsub_topic.scheduler_topic.name
}
