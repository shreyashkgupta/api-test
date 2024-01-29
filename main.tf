
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



resource "random_id" "randomID" {
  byte_length = 8
}



resource "google_firestore_database" "gcp-new-test-dev-users" {
  name                              = "gcp-new-test-dev-users"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "google_storage_bucket" "gcp-new-test-Dev-bucket" {
  name                        = "${random_id.randomID.hex-gcf-source}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_cloud_run_service_iam_member" "Dev_Create User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Create User.location
  service  = google_cloudfunctions2_function.cf_Dev_Create User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_storage_bucket" "gcp-new-test-Dev-bucket" {
  name                        = "${random_id.randomID.hex-gcf-source}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_cloud_run_service_iam_member" "Dev_Get User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Get User.location
  service  = google_cloudfunctions2_function.cf_Dev_Get User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_storage_bucket" "gcp-new-test-Dev-bucket" {
  name                        = "${random_id.randomID.hex-gcf-source}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_cloud_run_service_iam_member" "Dev_Update User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Update User.location
  service  = google_cloudfunctions2_function.cf_Dev_Update User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_storage_bucket" "gcp-new-test-Dev-bucket" {
  name                        = "${random_id.randomID.hex-gcf-source}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_cloud_run_service_iam_member" "Dev_Delete User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Delete User.location
  service  = google_cloudfunctions2_function.cf_Dev_Delete User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_storage_bucket" "gcp-new-test-Dev-bucket" {
  name                        = "${random_id.randomID.hex-gcf-source}"
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_cloud_run_service_iam_member" "Dev_List Users_member" {
  location = google_cloudfunctions2_function.cf_Dev_List Users.location
  service  = google_cloudfunctions2_function.cf_Dev_List Users.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
