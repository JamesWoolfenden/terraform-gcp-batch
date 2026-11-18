# Resolve *.googleapis.com to the private.googleapis.com VIPs inside the
# network, so API traffic follows the Private Google Access route.
# holden:ignore:HLD_GCP_132: private zone; its queries are logged by google_dns_policy.batch (enable_logging) on the same network
resource "google_dns_managed_zone" "googleapis" {
  name        = "batch-googleapis"
  dns_name    = "googleapis.com."
  description = "Private Google Access for the Batch worker network"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.batch.id
    }
  }
}
