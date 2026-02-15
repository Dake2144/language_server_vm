# =============================================================================
# Variables Definition
# =============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "talant-center-prod-vm"
}

variable "machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "e2-medium" # 2 vCPUs, 4 GB Memory
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 30
}

variable "boot_disk_type" {
  description = "Boot disk type"
  type        = string
  default     = "pd-balanced" # Balanced persistent disk
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork name (optional)"
  type        = string
  default     = null
}

variable "use_static_ip" {
  description = "Whether to use a static external IP"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Service account email for the VM"
  type        = string
  default     = null
}

variable "ssh_allowed_ips" {
  description = "List of IP ranges allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production!
}

variable "app_ports" {
  description = "Additional application ports to open"
  type        = list(string)
  default     = ["8080", "3000"] # Common app ports
}
