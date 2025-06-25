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
data "google_service_account" "accounts" {
  for_each = {
    for sa in var.service_accounts : sa.name => sa
  }

  account_id = each.value.name
  project    = var.project_id
}

