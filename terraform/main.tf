terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "1.47.0-beta2"
    }
  }
}

provider "ibm" {
  # Configuration options
}

data "ibm_resource_group" "default_group" {
  name = "default"
}

resource "random_string" "bucket_id" {
  length            = 8
  special           = false
  upper             = false
}

data "ibm_resource_instance" "cos_instance" {
  name              = "CloudObjectStorage"
  resource_group_id = data.ibm_resource_group.default_group.id
  service           = "cloud-object-storage"
  location          = "global"
}

resource "ibm_cos_bucket" "policy_as_code_bucket" {
  bucket_name          = "policyascode${random_string.bucket_id.result}"
  resource_instance_id = data.ibm_resource_instance.cos_instance.id
  region_location      = "us-south"
  storage_class        = "standard"
  endpoint_type        = "direct"
}
