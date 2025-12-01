# Specify the required Terraform version for this configuration.
terraform {
  required_version = ">=1.0.0, <2.0"

  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

# NEW Service ID
locals {
  iam_id = "iam-ServiceId-7a97ee6f-5862-44ce-be43-6d13dbdd6f3d"
}

# IBM Cloud API Key
variable "ibmcloud_api_key" {}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

# Custom role for COS
resource "ibm_iam_custom_role" "cos_custom_role" {
  name         = "CloudabilityStorageCustomRole"
  display_name = "CloudabilityStorageCustomRole"
  description  = "This is a custom role to read Cloud Storage"
  service      = "cloud-object-storage"

  actions = [
    "iam.policy.read",
    "cloud-object-storage.object.head",
    "cloud-object-storage.object.get_uploads",
    "cloud-object-storage.object.get",
    "cloud-object-storage.bucket.list_bucket_crn",
    "cloud-object-storage.bucket.head",
    "cloud-object-storage.bucket.get"
  ]
}

# IAM Service Policy for Cloud Object Storage
resource "ibm_iam_service_policy" "storage_policy" {
  iam_id = local.iam_id

  roles = [
    ibm_iam_custom_role.cos_custom_role.display_name
  ]

  resource_attributes {
    name     = "resource"
    value    = "daily-cost-exports-cloudability"
    operator = "stringEquals"
  }

  resource_attributes {
    name     = "serviceName"
    value    = "cloud-object-storage"
    operator = "stringEquals"
  }
}

# IAM Service Policy for Billing
resource "ibm_iam_service_policy" "billing_policy" {
  iam_id = local.iam_id
  roles  = ["Viewer"]

  resource_attributes {
    name     = "serviceName"
    value    = "billing"
    operator = "stringEquals"
  }
}
