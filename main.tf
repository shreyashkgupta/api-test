
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
  project = var.project_id
}



resource "google_firestore_database" "dev-user" {
  name                              = "dev-user"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "google_firestore_database" "dev-group" {
  name                              = "dev-group"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}
