# holden:ignore:HLD_GCP_093: Just enough to drive the module
resource "google_compute_network" "batch" {
  name                            = "batch-network"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}
