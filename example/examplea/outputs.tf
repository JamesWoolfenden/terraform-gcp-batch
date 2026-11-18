output "instance_template" {
  value       = module.batch.instance_template
  description = "Instance template to reference from gcloud batch jobs submit"
}

output "service_account_email" {
  value       = module.batch.service_account_email
  description = "Batch worker service account"
}
