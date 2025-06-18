provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "vm_instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network = var.network
    access_config {} # 외부 IP 부여
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.public_key_path)}"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "default-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-ssh"]
}
