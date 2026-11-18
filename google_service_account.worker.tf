resource "google_service_account" "worker" {
  account_id   = var.service_account_id
  display_name = "Dedicated SA for Cloud Batch workers (${var.name})"
  description  = "Runs Cloud Batch job VMs created from the ${var.name} instance template"
}
