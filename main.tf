
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



resource "google_firestore_database" "okay-test-Dev-User" {
  name                              = "okay-test-Dev-User"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}
