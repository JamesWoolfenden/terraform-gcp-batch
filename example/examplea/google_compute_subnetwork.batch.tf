resource "google_compute_subnetwork" "batch" {
  name                     = "batch-workers"
  ip_cidr_range            = "10.121.0.0/24"
  region                   = "europe-west2"
  network                  = google_compute_network.batch.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
