# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "batch" {
  source             = "../../"
  name               = "example-batch"
  service_account_id = "batch-worker"
  source_image       = data.google_compute_image.batch.self_link
  subnetwork         = google_compute_subnetwork.batch.id
  kms_key_name       = google_kms_crypto_key.batch.id

  labels = {
    workload = "batch"
  }
}
