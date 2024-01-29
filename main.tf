
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

variable "project_id" {
    type = string
    description = "Project ID"
}

provider "google" {
  region = "us-west2"
  zone = "us-west2a"
  project = var.project_id
}



resource "random_id" "randomID" {{
  byte_length = 8
}}



resource "google_firestore_database" "gcp-new-test-dev-users" {
  name                              = "gcp-new-test-dev-users"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}
