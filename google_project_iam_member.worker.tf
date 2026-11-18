# Minimum roles a Batch worker VM needs: report agent state back to the Batch
# service, and write task logs to Cloud Logging.
resource "google_project_iam_member" "worker" {
  for_each = toset(["roles/batch.agentReporter", "roles/logging.logWriter"])
  project  = data.google_project.current.project_id
  role     = each.value
  member   = google_service_account.worker.member
}
