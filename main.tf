
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
  provider = var.project_id
}



resource "google_firestore_database" "terra-gcp-test-Dev-users" {
  name                              = "terra-gcp-test-Dev-users"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}
