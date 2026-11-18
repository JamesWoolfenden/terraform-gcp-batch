# Logs every DNS query made from the worker network, including the private
# googleapis.com zone (private zones take query logging from a DNS policy).
resource "google_dns_policy" "batch" {
  name           = "batch-network-dns"
  enable_logging = true

  networks {
    network_url = google_compute_network.batch.id
  }
}
