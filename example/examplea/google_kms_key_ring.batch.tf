resource "google_kms_key_ring" "batch" {
  name     = "batch-keyring"
  location = "europe-west2"
}
