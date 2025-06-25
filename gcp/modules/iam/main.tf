resource "google_service_account" "accounts" {
  for_each    = { for sa in var.service_accounts : sa.name => sa }
  account_id  = each.value.name
  display_name = "${each.value.name} service account"
  project     = var.project_id
}

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

resource "google_project_iam_member" "bindings" {
  for_each = {
    for b in local.iam_bindings : b.key => b
  }

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.sa_email}"

  depends_on = [google_service_account.accounts]
}
