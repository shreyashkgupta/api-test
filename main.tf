
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  region = "us-west2"
  zone = "us-west2a"
}



resource "google_firestore_database" "terra-gcp-test-Dev-users" {
  name                              = "terra-gcp-test-Dev-users"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}
