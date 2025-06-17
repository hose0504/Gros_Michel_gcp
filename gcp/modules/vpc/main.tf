provider "google" {
  project     = var.project_id
  region      = var.subnets[0].region  # 첫 번째 subnet의 region 사용
  credentials = file("gcp-key.json")
}

# VPC 생성
resource "google_compute_network" "main_vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

# Subnet 여러 개 생성
resource "google_compute_subnetwork" "subnets" {
  for_each      = { for subnet in var.subnets : subnet.name => subnet }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.main_vpc.id
}
