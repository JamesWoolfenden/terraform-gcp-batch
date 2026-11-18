data "google_compute_image" "batch" {
  family  = "batch-debian-12-official"
  project = "batch-custom-image"
}
