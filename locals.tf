locals {
  # The Compute Engine Service Agent creates the Batch worker VMs and must be
  # able to use the CMEK key that encrypts their boot disks.
  compute_service_agent = "serviceAccount:service-${data.google_project.current.number}@compute-system.iam.gserviceaccount.com"
}
