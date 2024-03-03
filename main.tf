
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

provider "google" {
  region = "us-west2"
  project = var.project_id
}



resource "google_firestore_database" "dev-user-data" {
  name                              = "dev-user-data"
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

resource "random_id" "dev-get-users-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-users-bucket" {
  name                        = "${random_id.dev-get-users-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_get-users" {
type        = "zip"
source_dir  = "cloudfunctions/get-users"
output_path = "cloudfunctions/get-users.zip"
}

resource "google_storage_bucket_object" "dev-get-users-object" {
  name   = "dev-get-users-source.zip"
  bucket = google_storage_bucket.dev-get-users-bucket.name
  source = data.archive_file.zip_the_python_code_dev_get-users.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-get-users" {
  name        = "cf-dev-get-users"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-get-users-bucket.name
        object = google_storage_bucket_object.dev-get-users-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-get-users-member" {
  location = google_cloudfunctions2_function.cf-dev-get-users.location
  service  = google_cloudfunctions2_function.cf-dev-get-users.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-login-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-login-user-bucket" {
  name                        = "${random_id.dev-login-user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_login-user" {
type        = "zip"
source_dir  = "cloudfunctions/login-user"
output_path = "cloudfunctions/login-user.zip"
}

resource "google_storage_bucket_object" "dev-login-user-object" {
  name   = "dev-login-user-source.zip"
  bucket = google_storage_bucket.dev-login-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_login-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-login-user" {
  name        = "cf-dev-login-user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-login-user-bucket.name
        object = google_storage_bucket_object.dev-login-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-login-user-member" {
  location = google_cloudfunctions2_function.cf-dev-login-user.location
  service  = google_cloudfunctions2_function.cf-dev-login-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-logout-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-logout-user-bucket" {
  name                        = "${random_id.dev-logout-user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_logout-user" {
type        = "zip"
source_dir  = "cloudfunctions/logout-user"
output_path = "cloudfunctions/logout-user.zip"
}

resource "google_storage_bucket_object" "dev-logout-user-object" {
  name   = "dev-logout-user-source.zip"
  bucket = google_storage_bucket.dev-logout-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_logout-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-logout-user" {
  name        = "cf-dev-logout-user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-logout-user-bucket.name
        object = google_storage_bucket_object.dev-logout-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-logout-user-member" {
  location = google_cloudfunctions2_function.cf-dev-logout-user.location
  service  = google_cloudfunctions2_function.cf-dev-logout-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
