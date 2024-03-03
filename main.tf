
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

resource "random_id" "dev-create-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-create-user-bucket" {
  name                        = "${random_id.dev-create-user-randomID.hex}-gcf-source"
  location                    = "US"
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
  location    = "us-west2"

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

resource "random_id" "dev-get-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-user-bucket" {
  name                        = "${random_id.dev-get-user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_get-user" {
type        = "zip"
source_dir  = "cloudfunctions/get-user"
output_path = "cloudfunctions/get-user.zip"
}

resource "google_storage_bucket_object" "dev-get-user-object" {
  name   = "dev-get-user-source.zip"
  bucket = google_storage_bucket.dev-get-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_get-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-get-user" {
  name        = "cf-dev-get-user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-get-user-bucket.name
        object = google_storage_bucket_object.dev-get-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-get-user-member" {
  location = google_cloudfunctions2_function.cf-dev-get-user.location
  service  = google_cloudfunctions2_function.cf-dev-get-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-update-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-update-user-bucket" {
  name                        = "${random_id.dev-update-user-randomID.hex}-gcf-source"
  location                    = "US"
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
  location    = "us-west2"

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
  location                    = "US"
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
  location    = "us-west2"

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
