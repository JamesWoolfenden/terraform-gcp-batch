# The network deletes its default routes and workers have no external IP, so
# they reach Google APIs (the Batch agent reporting state, Cloud Logging) only
# through Private Google Access on private.googleapis.com. This route and the
# googleapis.com private zone below are what make that work; without them the
# workers cannot report state and every job hangs.
resource "google_compute_route" "private_google_access" {
  name             = "batch-private-google-access"
  network          = google_compute_network.batch.id
  dest_range       = "199.36.153.8/30"
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}
