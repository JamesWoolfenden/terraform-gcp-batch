# terraform-gcp-batch

[![Build Status](https://github.com/JamesWoolfenden/terraform-gcp-batch/workflows/Verify/badge.svg?branch=main)](https://github.com/JamesWoolfenden/terraform-gcp-batch/actions)
[![Latest Release](https://img.shields.io/github/release/JamesWoolfenden/terraform-gcp-batch.svg)](https://github.com/JamesWoolfenden/terraform-gcp-batch/releases/latest)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/JamesWoolfenden/terraform-gcp-batch.svg?label=latest)](https://github.com/JamesWoolfenden/terraform-gcp-batch/releases/latest)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.5.0-blue.svg)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

Terraform module for the reusable pieces of a Cloud Batch workload. The `google` provider (7.31.0) has no Batch job resource, so the module builds what jobs reference: a global instance template for the workers (Shielded and Confidential VM, no external IP, CMEK-encrypted boot disk, OS Login with project SSH keys blocked), a dedicated worker service account with only `roles/batch.agentReporter` and `roles/logging.logWriter`, and the Compute Engine service agent's grant on the CMEK key. Batch only accepts global instance templates, which is why this is not a regional template. The worker uses the `cloud-platform` OAuth scope because the Batch API accepts no narrower scope; access is limited by the SA's IAM roles.

## Usage

Add **module.batch.tf** to your code:-

```terraform
module "batch" {
  source             = "jameswoolfenden/batch/gcp"
  name               = "example-batch"
  service_account_id = "batch-worker"
  source_image       = data.google_compute_image.batch.self_link
  subnetwork         = google_compute_subnetwork.batch.id
  kms_key_name       = google_kms_crypto_key.batch.id
}
```

Then submit jobs that use the template. The template sets the service account, network and disks, so the job config only references it:

```shell
cat > job.json <<JSON
{
  "taskGroups": [{
    "taskSpec": {
      "runnables": [{ "script": { "text": "echo hello from task \$BATCH_TASK_INDEX" } }],
      "maxRetryCount": 2,
      "maxRunDuration": "600s"
    },
    "taskCount": 4,
    "parallelism": 2
  }],
  "allocationPolicy": {
    "instances": [{ "instanceTemplate": "$(tofu output -raw instance_template)" }]
  },
  "logsPolicy": { "destination": "CLOUD_LOGGING" }
}
JSON

gcloud batch jobs submit example-job --location=europe-west2 --config=job.json
```

The identity that submits jobs needs `roles/batch.jobsEditor` and `roles/iam.serviceAccountUser` on the worker service account. See [example/examplea](example/examplea) for a complete working example.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_instance_template.worker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_kms_crypto_key_iam_member.compute_service_agent](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_project_iam_member.worker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.worker](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [data.google_project.current](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_boot_disk_size_gb"></a> [boot\_disk\_size\_gb](#input\_boot\_disk\_size\_gb) | Boot disk size, in GB | `number` | `50` | no |
| <a name="input_enable_confidential_compute"></a> [enable\_confidential\_compute](#input\_enable\_confidential\_compute) | Run the workers as Confidential VMs (AMD SEV). Requires an SEV capable machine type and image (the batch-debian-12-official images are) | `bool` | `true` | no |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Cloud KMS key used to encrypt worker boot disks (CMEK); must be in the region the Batch jobs run in | `string` | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels applied to the instance template and its workers | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type of the Batch workers; must be an AMD SEV capable family (N2D, C2D, C3D) while var.enable\_confidential\_compute is true | `string` | `"n2d-standard-2"` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name of the Batch worker instance template | `string` | n/a | yes |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | account\_id of the dedicated service account the module creates for the Batch workers | `string` | n/a | yes |
| <a name="input_source_image"></a> [source\_image](#input\_source\_image) | Boot image for the workers, ideally a pinned batch-debian or batch-cos image | `string` | n/a | yes |
| <a name="input_spot"></a> [spot](#input\_spot) | Use Spot VMs for the workers (cheaper, preemptible) | `bool` | `false` | no |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Self-link or ID of the subnetwork workers attach to. No access config is set, so workers get no external IP; enable Private Google Access on it | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_instance_template"></a> [instance\_template](#output\_instance\_template) | Self-link of the instance template, for allocationPolicy.instances[].instanceTemplate in a Batch job |
| <a name="output_instance_template_name"></a> [instance\_template\_name](#output\_instance\_template\_name) | Name of the instance template |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | Email of the dedicated Batch worker service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Role and Permissions

<!-- BEGINNING OF PRE-COMMIT-PIKE DOCS HOOK -->
The Terraform resource required is:

```golang
# apply role
resource "google_project_iam_custom_role" "terraform_pike" {
  project     = "pike-477416"
  role_id     = "terraform_pike"
  title       = "terraform_pike"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "cloudkms.cryptoKeys.setIamPolicy",
    "compute.instanceTemplates.create",
    "compute.instanceTemplates.delete",
    "compute.instanceTemplates.get",
    "compute.networks.get",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.delete",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.update",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy"
  ]
}

# plan role
resource "google_project_iam_custom_role" "terraform_pike_plan" {
  project     = "pike-477416"
  role_id     = "terraform_pike_plan"
  title       = "terraform_pike_plan"
  description = "A user with least privileges"
  permissions = [
    "cloudkms.cryptoKeys.getIamPolicy",
    "compute.instanceTemplates.get",
    "compute.networks.get",
    "iam.serviceAccounts.get",
    "resourcemanager.projects.get",
    "resourcemanager.projects.getIamPolicy"
  ]
}


```
<!-- END OF PRE-COMMIT-PIKE DOCS HOOK -->

## Help

**Got a question?**

File a GitHub [issue](https://github.com/jameswoolfenden/terraform-gcp-batch/issues).

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/jameswoolfenden/terraform-gcp-batch/issues) to report any bugs or file feature requests.

## Copyrights

Copyright © 2026 James Woolfenden

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements. See the NOTICE file
distributed with this work for additional information
regarding copyright ownership. The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at

<https://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied. See the License for the
specific language governing permissions and limitations
under the License.

### Contributors

[![James Woolfenden][jameswoolfenden_avatar]][jameswoolfenden_homepage]<br/>[James Woolfenden][jameswoolfenden_homepage]

[jameswoolfenden_homepage]: https://github.com/jameswoolfenden
[jameswoolfenden_avatar]: https://github.com/jameswoolfenden.png?size=150
