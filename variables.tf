variable "name" {
  type        = string
  description = "Base name of the Batch worker instance template"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{0,35}$", var.name))
    error_message = "var.name must be lowercase, start with a letter and be at most 36 characters"
  }
}

variable "service_account_id" {
  type        = string
  description = "account_id of the dedicated service account the module creates for the Batch workers"

  validation {
    condition     = can(regex("^[a-z][-a-z0-9]{4,28}[a-z0-9]$", var.service_account_id))
    error_message = "var.service_account_id must be 6-30 lowercase letters, digits or hyphens, starting with a letter"
  }
}

variable "machine_type" {
  type        = string
  description = "Machine type of the Batch workers; must be an AMD SEV capable family (N2D, C2D, C3D) while var.enable_confidential_compute is true"
  default     = "n2d-standard-2"

  validation {
    condition     = length(trimspace(var.machine_type)) > 0
    error_message = "var.machine_type must be a non-empty string"
  }
}

variable "source_image" {
  type        = string
  description = "Boot image for the workers, ideally a pinned batch-debian or batch-cos image"

  validation {
    condition     = length(trimspace(var.source_image)) > 0
    error_message = "var.source_image must be a non-empty string"
  }
}

variable "boot_disk_size_gb" {
  type        = number
  description = "Boot disk size, in GB"
  default     = 50

  validation {
    condition     = var.boot_disk_size_gb >= 10
    error_message = "var.boot_disk_size_gb must be at least 10"
  }
}

variable "subnetwork" {
  type        = string
  description = "Self-link or ID of the subnetwork workers attach to. No access config is set, so workers get no external IP; enable Private Google Access on it"

  validation {
    condition     = length(trimspace(var.subnetwork)) > 0
    error_message = "var.subnetwork must be a non-empty string"
  }
}

variable "kms_key_name" {
  type        = string
  description = "Cloud KMS key used to encrypt worker boot disks (CMEK); must be in the region the Batch jobs run in"
  sensitive   = true

  validation {
    condition     = can(regex("^projects/[^/]+/locations/[^/]+/keyRings/[^/]+/cryptoKeys/[^/]+$", var.kms_key_name))
    error_message = "var.kms_key_name must be a KMS key id of the form projects/P/locations/L/keyRings/R/cryptoKeys/K"
  }
}

variable "enable_confidential_compute" {
  type        = bool
  description = "Run the workers as Confidential VMs (AMD SEV). Requires an SEV capable machine type and image (the batch-debian-12-official images are)"
  default     = true

  validation {
    condition     = var.enable_confidential_compute != null
    error_message = "var.enable_confidential_compute must not be null"
  }
}

variable "spot" {
  type        = bool
  description = "Use Spot VMs for the workers (cheaper, preemptible)"
  default     = false

  validation {
    condition     = var.spot != null
    error_message = "var.spot must not be null"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to the instance template and its workers"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys must start with a lowercase letter and keys/values must be lowercase alphanumerics, underscores, or hyphens, up to 63 characters (GCP label constraints)"
  }
}
