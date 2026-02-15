# =============================================================================
# Outputs
# =============================================================================

output "instance_name" {
  description = "Name of the VM instance"
  value       = google_compute_instance.talant_center_prod.name
}

output "instance_id" {
  description = "Instance ID"
  value       = google_compute_instance.talant_center_prod.instance_id
}

output "external_ip" {
  description = "External IP address of the VM"
  value       = google_compute_instance.talant_center_prod.network_interface[0].access_config[0].nat_ip
}

output "internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.talant_center_prod.network_interface[0].network_ip
}

output "zone" {
  description = "Zone where the VM is located"
  value       = google_compute_instance.talant_center_prod.zone
}

output "machine_type" {
  description = "Machine type of the VM"
  value       = google_compute_instance.talant_center_prod.machine_type
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "gcloud compute ssh ${google_compute_instance.talant_center_prod.name} --zone=${var.zone} --project=${var.project_id}"
}

output "static_ip" {
  description = "Static IP address (if enabled)"
  value       = var.use_static_ip ? google_compute_address.static_ip[0].address : null
}
