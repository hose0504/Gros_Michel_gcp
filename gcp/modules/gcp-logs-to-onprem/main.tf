provider "google" {
  project = var.project_id
  region  = var.region
}

# GCS Bucket
resource "google_storage_bucket" "log_bucket" {
  name          = "${var.project_id}-log-bucket"
  location      = var.region
  project       = var.project_id
  force_destroy = true
}

# Function ZIP 업로드
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.log_bucket.name
  source = "${path.module}/function-source.zip"

}

# Cloud Function
resource "google_cloudfunctions_function" "log_to_onprem" {
  name        = "log-to-onprem"
  runtime     = "python39"
  entry_point = "lambda_handler"

  source_archive_bucket = google_storage_bucket.log_bucket.name
  source_archive_object = google_storage_bucket_object.function_zip.name

  trigger_http = true

  available_memory_mb = 128
  timeout             = 60
  project             = var.project_id

  environment_variables = {
    ONPREM_API_URL = var.onprem_api_url
  }

  https_trigger_security_level = "SECURE_ALWAYS"
}

# Pub/Sub Topic
resource "google_pubsub_topic" "scheduler_topic" {
  name    = "log-export-scheduler"
  project = var.project_id
}

# Cloud Scheduler → Pub/Sub
resource "google_cloud_scheduler_job" "every_minute" {
  name      = "every-minute-export"
  schedule  = "* * * * *" # 매 분
  time_zone = "Etc/UTC"
  project   = var.project_id

  pubsub_target {
    topic_name = google_pubsub_topic.scheduler_topic.id
    data       = base64encode("trigger")
  }
}

# Pub/Sub → Cloud Function 권한 부여
resource "google_cloudfunctions_function_iam_member" "allow_pubsub_invoker" {
  project        = var.project_id
  region         = google_cloudfunctions_function.log_to_onprem.region
  cloud_function = google_cloudfunctions_function.log_to_onprem.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${var.pubsub_sa_email}"

  depends_on = [google_service_account.sa_admin_001]
}


