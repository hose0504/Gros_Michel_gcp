resource "google_storage_bucket" "this" {
  name                        = var.bucket_name
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = var.main_page_suffix
    not_found_page   = var.not_found_page
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
}

# 퍼블릭 읽기 권한 (선택적)
resource "google_storage_bucket_iam_member" "public_access" {
  count = var.public_access ? 1 : 0

  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
