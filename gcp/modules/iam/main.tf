# 서비스 계정 생성
resource "google_service_account" "accounts" {
  for_each = { for sa in var.service_accounts : sa.name => sa }

  account_id   = each.value.name
  display_name = "${each.value.name} service account"
}

# 중첩 for는 local에서 먼저 처리
locals {
  iam_bindings = flatten([
    for sa in var.service_accounts : [
      for role in sa.roles : {
        key      = "${sa.name}-${role}"
        sa_email = "${sa.name}@${var.project_id}.iam.gserviceaccount.com"
        role     = role
      }
    ]
  ])
}

# IAM 역할 바인딩
resource "google_project_iam_member" "bindings" {
  for_each = {
    for sa in var.service_accounts : "${sa.name}-${sa.roles[0]}" => {
      role   = sa.roles[0]
      member = "serviceAccount:${sa.name}@${var.project_id}.iam.gserviceaccount.com"
    }
  }

  project = var.project_id
  role    = each.value.role
  member  = each.value.member

  depends_on = [google_service_account.accounts]
}

