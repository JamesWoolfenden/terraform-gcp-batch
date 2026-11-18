output "instance_template" {
  value       = google_compute_instance_template.worker.self_link
  description = "Self-link of the instance template, for allocationPolicy.instances[].instanceTemplate in a Batch job"
}

output "instance_template_name" {
  value       = google_compute_instance_template.worker.name
  description = "Name of the instance template"
}

output "service_account_email" {
  value       = google_service_account.worker.email
  description = "Email of the dedicated Batch worker service account"
}
