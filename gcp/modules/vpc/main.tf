provider "google" {
  project     = var.project_id
  credentials = var.gcp_credentials
  # region은 생략 가능 (서브넷마다 따로 region 지정하므로)
}

# VPC 생성
resource "google_compute_network" "main_vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Subnet 여러 개 생성
resource "google_compute_subnetwork" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.main_vpc.id
  project       = var.project_id
}
