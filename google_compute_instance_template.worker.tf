# Cloud Batch only accepts global instance templates
# (allocationPolicy.instances[].instanceTemplate), so this is a
# google_compute_instance_template rather than a regional one.
# holden:ignore:HLD_GCP_076 — the Batch API (used by the on-VM agent to report
# state) only accepts the cloud-platform OAuth scope. Access is bounded by IAM
# instead: the dedicated SA holds only roles/batch.agentReporter and
# roles/logging.logWriter.
resource "google_compute_instance_template" "worker" {
  name_prefix  = "${var.name}-"
  machine_type = var.machine_type
  description  = "Cloud Batch worker template for ${var.name}"

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
    disk_size_gb = var.boot_disk_size_gb

    disk_encryption_key {
      kms_key_self_link = var.kms_key_name
    }
  }

  # No access_config block: workers get no external IP and reach Google APIs
  # through Private Google Access on the subnetwork.
  network_interface {
    subnetwork = var.subnetwork
  }

  service_account {
    email  = google_service_account.worker.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  confidential_instance_config {
    enable_confidential_compute = var.enable_confidential_compute
  }

  scheduling {
    provisioning_model = var.spot ? "SPOT" : "STANDARD"
    preemptible        = var.spot
    automatic_restart  = !var.spot
    # Spot and Confidential VMs cannot live migrate
    on_host_maintenance = var.spot || var.enable_confidential_compute ? "TERMINATE" : "MIGRATE"
  }

  metadata = {
    "enable-oslogin"         = "true"
    "block-project-ssh-keys" = "true"
  }

  can_ip_forward = false
  labels         = var.labels

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = !var.enable_confidential_compute || can(regex("^(n2d|c2d|c3d|c4d)-", var.machine_type))
      error_message = "var.enable_confidential_compute requires an AMD SEV capable machine type (n2d-, c2d-, c3d- or c4d-); set var.enable_confidential_compute = false to use ${var.machine_type}"
    }
  }

  depends_on = [google_kms_crypto_key_iam_member.compute_service_agent]
}
