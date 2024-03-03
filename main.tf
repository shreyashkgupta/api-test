
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
    default = ""
    description = "Project ID"
}

variable "region" {
    type = string
    default = "us-west2"
    description = "Region"
}

provider "google" {
  region = var.region
  project = var.project_id
}



resource "google_firestore_database" "dev-user-management" {
  name                              = "dev-user-management"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "random_id" "dev-create-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-create-user-bucket" {
  name                        = "${random_id.dev-create-user-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_create-user" {
type        = "zip"
source_dir  = "cloudfunctions/create-user"
output_path = "cloudfunctions/create-user.zip"
}

resource "google_storage_bucket_object" "dev-create-user-object" {
  name   = "dev-create-user-source.zip"
  bucket = google_storage_bucket.dev-create-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_create-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-create-user" {
  name        = "cf-dev-create-user"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-create-user-bucket.name
        object = google_storage_bucket_object.dev-create-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-create-user-member" {
  location = google_cloudfunctions2_function.cf-dev-create-user.location
  service  = google_cloudfunctions2_function.cf-dev-create-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-update-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-update-user-bucket" {
  name                        = "${random_id.dev-update-user-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_update-user" {
type        = "zip"
source_dir  = "cloudfunctions/update-user"
output_path = "cloudfunctions/update-user.zip"
}

resource "google_storage_bucket_object" "dev-update-user-object" {
  name   = "dev-update-user-source.zip"
  bucket = google_storage_bucket.dev-update-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_update-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-update-user" {
  name        = "cf-dev-update-user"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-update-user-bucket.name
        object = google_storage_bucket_object.dev-update-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-update-user-member" {
  location = google_cloudfunctions2_function.cf-dev-update-user.location
  service  = google_cloudfunctions2_function.cf-dev-update-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-delete-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-delete-user-bucket" {
  name                        = "${random_id.dev-delete-user-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_delete-user" {
type        = "zip"
source_dir  = "cloudfunctions/delete-user"
output_path = "cloudfunctions/delete-user.zip"
}

resource "google_storage_bucket_object" "dev-delete-user-object" {
  name   = "dev-delete-user-source.zip"
  bucket = google_storage_bucket.dev-delete-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_delete-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-delete-user" {
  name        = "cf-dev-delete-user"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-delete-user-bucket.name
        object = google_storage_bucket_object.dev-delete-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-delete-user-member" {
  location = google_cloudfunctions2_function.cf-dev-delete-user.location
  service  = google_cloudfunctions2_function.cf-dev-delete-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-get-user-by-id-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-user-by-id-bucket" {
  name                        = "${random_id.dev-get-user-by-id-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_get-user-by-id" {
type        = "zip"
source_dir  = "cloudfunctions/get-user-by-id"
output_path = "cloudfunctions/get-user-by-id.zip"
}

resource "google_storage_bucket_object" "dev-get-user-by-id-object" {
  name   = "dev-get-user-by-id-source.zip"
  bucket = google_storage_bucket.dev-get-user-by-id-bucket.name
  source = data.archive_file.zip_the_python_code_dev_get-user-by-id.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-get-user-by-id" {
  name        = "cf-dev-get-user-by-id"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-get-user-by-id-bucket.name
        object = google_storage_bucket_object.dev-get-user-by-id-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-get-user-by-id-member" {
  location = google_cloudfunctions2_function.cf-dev-get-user-by-id.location
  service  = google_cloudfunctions2_function.cf-dev-get-user-by-id.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-get-all-users-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-all-users-bucket" {
  name                        = "${random_id.dev-get-all-users-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_get-all-users" {
type        = "zip"
source_dir  = "cloudfunctions/get-all-users"
output_path = "cloudfunctions/get-all-users.zip"
}

resource "google_storage_bucket_object" "dev-get-all-users-object" {
  name   = "dev-get-all-users-source.zip"
  bucket = google_storage_bucket.dev-get-all-users-bucket.name
  source = data.archive_file.zip_the_python_code_dev_get-all-users.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-get-all-users" {
  name        = "cf-dev-get-all-users"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-get-all-users-bucket.name
        object = google_storage_bucket_object.dev-get-all-users-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-get-all-users-member" {
  location = google_cloudfunctions2_function.cf-dev-get-all-users.location
  service  = google_cloudfunctions2_function.cf-dev-get-all-users.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
