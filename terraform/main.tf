# =============================================================================
# GCP Infrastructure - Talant Center Production
# =============================================================================

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Uncomment to use remote state (recommended for production)
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state"
  # }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# -----------------------------------------------------------------------------
# Compute Instance - Production VM
# -----------------------------------------------------------------------------
resource "google_compute_instance" "talant_center_prod" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["http-server", "https-server", "ssh"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
      # Ephemeral public IP - comment out if using static IP
    }
  }

  # Startup script to install Docker
  metadata_startup_script = file("${path.module}/scripts/startup.sh")

  metadata = {
    enable-oslogin = "TRUE"
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  # Allow stopping for update
  allow_stopping_for_update = true

  labels = {
    environment = "production"
    project     = "talant-center"
    managed_by  = "terraform"
  }

  lifecycle {
    # Prevent accidental deletion of production VM
    prevent_destroy = false # Set to true in production
  }
}

# -----------------------------------------------------------------------------
# Static External IP (Optional - recommended for production)
# -----------------------------------------------------------------------------
resource "google_compute_address" "static_ip" {
  count        = var.use_static_ip ? 1 : 0
  name         = "${var.instance_name}-ip"
  region       = var.region
  address_type = "EXTERNAL"
}

# -----------------------------------------------------------------------------
# Firewall Rules
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "allow_http" {
  name    = "${var.instance_name}-allow-http"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "${var.instance_name}-allow-https"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.instance_name}-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Restrict SSH access to specific IPs in production
  source_ranges = var.ssh_allowed_ips
  target_tags   = ["ssh"]
}

# Custom application ports (if needed)
resource "google_compute_firewall" "allow_app_ports" {
  count   = length(var.app_ports) > 0 ? 1 : 0
  name    = "${var.instance_name}-allow-app-ports"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = var.app_ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}
