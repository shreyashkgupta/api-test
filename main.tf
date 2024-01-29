
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



resource "google_firestore_database" "work-dev-user_data" {
  name                              = "work-dev-user_data"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "random_id" "work-Dev-create_user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "work-Dev-create_user-bucket" {
  name                        = "${random_id.work-Dev-create_user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_create_user" {
type        = "zip"
source_dir  = "lambdas/create_user"
output_path = "lambdas/create_user.zip"
}

resource "google_storage_bucket_object" "work-Dev-create_user-object" {
  name   = "Dev-create_user-source.zip"
  bucket = google_storage_bucket.work-Dev-create_user-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_create_user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_create_user" {
  name        = "work-Dev-create_user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.work-Dev-create_user-bucket.name
        object = google_storage_bucket_object.work-Dev-create_user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_create_user_member" {
  location = google_cloudfunctions2_function.cf_Dev_create_user.location
  service  = google_cloudfunctions2_function.cf_Dev_create_user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "work-Dev-get_user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "work-Dev-get_user-bucket" {
  name                        = "${random_id.work-Dev-get_user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_get_user" {
type        = "zip"
source_dir  = "lambdas/get_user"
output_path = "lambdas/get_user.zip"
}

resource "google_storage_bucket_object" "work-Dev-get_user-object" {
  name   = "Dev-get_user-source.zip"
  bucket = google_storage_bucket.work-Dev-get_user-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_get_user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_get_user" {
  name        = "work-Dev-get_user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.work-Dev-get_user-bucket.name
        object = google_storage_bucket_object.work-Dev-get_user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_get_user_member" {
  location = google_cloudfunctions2_function.cf_Dev_get_user.location
  service  = google_cloudfunctions2_function.cf_Dev_get_user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "work-Dev-update_user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "work-Dev-update_user-bucket" {
  name                        = "${random_id.work-Dev-update_user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_update_user" {
type        = "zip"
source_dir  = "lambdas/update_user"
output_path = "lambdas/update_user.zip"
}

resource "google_storage_bucket_object" "work-Dev-update_user-object" {
  name   = "Dev-update_user-source.zip"
  bucket = google_storage_bucket.work-Dev-update_user-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_update_user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_update_user" {
  name        = "work-Dev-update_user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.work-Dev-update_user-bucket.name
        object = google_storage_bucket_object.work-Dev-update_user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_update_user_member" {
  location = google_cloudfunctions2_function.cf_Dev_update_user.location
  service  = google_cloudfunctions2_function.cf_Dev_update_user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "work-Dev-delete_user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "work-Dev-delete_user-bucket" {
  name                        = "${random_id.work-Dev-delete_user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_delete_user" {
type        = "zip"
source_dir  = "lambdas/delete_user"
output_path = "lambdas/delete_user.zip"
}

resource "google_storage_bucket_object" "work-Dev-delete_user-object" {
  name   = "Dev-delete_user-source.zip"
  bucket = google_storage_bucket.work-Dev-delete_user-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_delete_user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_delete_user" {
  name        = "work-Dev-delete_user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.work-Dev-delete_user-bucket.name
        object = google_storage_bucket_object.work-Dev-delete_user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_delete_user_member" {
  location = google_cloudfunctions2_function.cf_Dev_delete_user.location
  service  = google_cloudfunctions2_function.cf_Dev_delete_user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
