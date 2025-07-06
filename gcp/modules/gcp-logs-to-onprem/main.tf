# ✅ GCS 버킷
resource "google_storage_bucket" "log_bucket" {
  name          = "${var.project_id}-log-bucket"
  location      = var.region
  project       = var.project_id
  force_destroy = true
}

# ✅ Cloud Function 코드 업로드
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.log_bucket.name
  source = "${path.module}/function-source.zip"
}

# ✅ Cloud Function 정의
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
  depends_on = [google_storage_bucket_object.function_zip]
}

# ✅ Pub/Sub 토픽 생성
resource "google_pubsub_topic" "scheduler_topic" {
  name    = "log-export-scheduler"
  project = var.project_id
}

# ✅ Cloud Scheduler 작업 생성
resource "google_cloud_scheduler_job" "every_minute" {
  name      = "every-minute-export"
  schedule  = "* * * * *"
  time_zone = "Etc/UTC"
  project   = var.project_id

  pubsub_target {
    topic_name = google_pubsub_topic.scheduler_topic.id
    data       = base64encode("trigger")
  }

  depends_on = [google_pubsub_topic.scheduler_topic]
}

# ✅ IAM 권한 부여: Pub/Sub → Cloud Function
resource "google_cloudfunctions_function_iam_member" "allow_pubsub_invoker" {
  project        = var.project_id
  region         = google_cloudfunctions_function.log_to_onprem.region
  cloud_function = google_cloudfunctions_function.log_to_onprem.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${var.pubsub_sa_email}"

  depends_on = [google_cloudfunctions_function.log_to_onprem]
}
