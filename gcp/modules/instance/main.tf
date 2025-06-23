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
    access_config {}
  }

  metadata = {
    "block-project-ssh-keys" = "true"
    ssh-keys                 = "${var.ssh_username}:${var.ssh_pub_key}"
    startup-script           = file("${path.module}/startup.sh")
  }
}


