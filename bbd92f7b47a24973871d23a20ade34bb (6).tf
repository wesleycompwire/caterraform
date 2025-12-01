# Specify the required Terraform version for this configuration.
terraform {
  required_version = ">=1.0.0, <2.0"

  # Define the required providers and their sources.
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

locals {
  # Define the IAM ID
  iam_id = "iam-ServiceId-6bf7af4e-6f07-4894-ab72-ff539dfb951a"
}

# Declare a variable for the IBM Cloud API key.
variable "ibmcloud_api_key" {}

# Define the IBM provider configuration and set the API key from the variable.
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

# Define a custom IAM role for Cloud Storage with specific actions.
resource "ibm_iam_custom_role" "cos_custom_role" {
  name         = "CloudabilityStorageCustomRole"
  display_name = "CloudabilityStorageCustomRole"
  description  = "This is a custom role to read Cloud Storage"
  service      = "cloud-object-storage"
  actions      = [
    "iam.policy.read",
    "cloud-object-storage.object.head",
    "cloud-object-storage.object.get_uploads",
    "cloud-object-storage.object.get",
    "cloud-object-storage.bucket.list_bucket_crn",
    "cloud-object-storage.bucket.head",
    "cloud-object-storage.bucket.get"
  ]
}

resource "ibm_iam_service_policy" "storage_policy" {
  iam_id         = local.iam_id
  roles         = [ibm_iam_custom_role.cos_custom_role.display_name]
  resource_attributes {
    name  = "resource"
    value = "daily-cost-exports-cloudability"
    operator = "stringEquals"
  }
  resource_attributes {
    name  = "serviceName"
    value = "cloud-object-storage"
  }
}

# Create another IAM access group policy for a different service with viewer role.
resource "ibm_iam_service_policy" "billing_policy" {
  iam_id         =  local.iam_id
  roles           = ["Viewer"]
  resources {
    service = "billing"
  }
}