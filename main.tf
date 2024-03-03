
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



resource "google_firestore_database" "dev-user" {
  name                              = "dev-user"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "google_firestore_database" "dev-role" {
  name                              = "dev-role"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "google_firestore_database" "dev-user-role" {
  name                              = "dev-user-role"
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

resource "random_id" "dev-get-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-user-bucket" {
  name                        = "${random_id.dev-get-user-randomID.hex}-gcf-source"
  location                    = var.region
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
  location    = var.region

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

resource "random_id" "dev-create-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-create-role-bucket" {
  name                        = "${random_id.dev-create-role-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_create-role" {
type        = "zip"
source_dir  = "cloudfunctions/create-role"
output_path = "cloudfunctions/create-role.zip"
}

resource "google_storage_bucket_object" "dev-create-role-object" {
  name   = "dev-create-role-source.zip"
  bucket = google_storage_bucket.dev-create-role-bucket.name
  source = data.archive_file.zip_the_python_code_dev_create-role.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-create-role" {
  name        = "cf-dev-create-role"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-create-role-bucket.name
        object = google_storage_bucket_object.dev-create-role-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-create-role-member" {
  location = google_cloudfunctions2_function.cf-dev-create-role.location
  service  = google_cloudfunctions2_function.cf-dev-create-role.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-get-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-role-bucket" {
  name                        = "${random_id.dev-get-role-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_get-role" {
type        = "zip"
source_dir  = "cloudfunctions/get-role"
output_path = "cloudfunctions/get-role.zip"
}

resource "google_storage_bucket_object" "dev-get-role-object" {
  name   = "dev-get-role-source.zip"
  bucket = google_storage_bucket.dev-get-role-bucket.name
  source = data.archive_file.zip_the_python_code_dev_get-role.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-get-role" {
  name        = "cf-dev-get-role"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-get-role-bucket.name
        object = google_storage_bucket_object.dev-get-role-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-get-role-member" {
  location = google_cloudfunctions2_function.cf-dev-get-role.location
  service  = google_cloudfunctions2_function.cf-dev-get-role.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-update-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-update-role-bucket" {
  name                        = "${random_id.dev-update-role-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_update-role" {
type        = "zip"
source_dir  = "cloudfunctions/update-role"
output_path = "cloudfunctions/update-role.zip"
}

resource "google_storage_bucket_object" "dev-update-role-object" {
  name   = "dev-update-role-source.zip"
  bucket = google_storage_bucket.dev-update-role-bucket.name
  source = data.archive_file.zip_the_python_code_dev_update-role.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-update-role" {
  name        = "cf-dev-update-role"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-update-role-bucket.name
        object = google_storage_bucket_object.dev-update-role-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-update-role-member" {
  location = google_cloudfunctions2_function.cf-dev-update-role.location
  service  = google_cloudfunctions2_function.cf-dev-update-role.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-delete-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-delete-role-bucket" {
  name                        = "${random_id.dev-delete-role-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_delete-role" {
type        = "zip"
source_dir  = "cloudfunctions/delete-role"
output_path = "cloudfunctions/delete-role.zip"
}

resource "google_storage_bucket_object" "dev-delete-role-object" {
  name   = "dev-delete-role-source.zip"
  bucket = google_storage_bucket.dev-delete-role-bucket.name
  source = data.archive_file.zip_the_python_code_dev_delete-role.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-delete-role" {
  name        = "cf-dev-delete-role"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-delete-role-bucket.name
        object = google_storage_bucket_object.dev-delete-role-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-delete-role-member" {
  location = google_cloudfunctions2_function.cf-dev-delete-role.location
  service  = google_cloudfunctions2_function.cf-dev-delete-role.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-add-user-to-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-add-user-to-role-bucket" {
  name                        = "${random_id.dev-add-user-to-role-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_add-user-to-role" {
type        = "zip"
source_dir  = "cloudfunctions/add-user-to-role"
output_path = "cloudfunctions/add-user-to-role.zip"
}

resource "google_storage_bucket_object" "dev-add-user-to-role-object" {
  name   = "dev-add-user-to-role-source.zip"
  bucket = google_storage_bucket.dev-add-user-to-role-bucket.name
  source = data.archive_file.zip_the_python_code_dev_add-user-to-role.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-add-user-to-role" {
  name        = "cf-dev-add-user-to-role"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-add-user-to-role-bucket.name
        object = google_storage_bucket_object.dev-add-user-to-role-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-add-user-to-role-member" {
  location = google_cloudfunctions2_function.cf-dev-add-user-to-role.location
  service  = google_cloudfunctions2_function.cf-dev-add-user-to-role.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-remove-user-from-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-remove-user-from-role-bucket" {
  name                        = "${random_id.dev-remove-user-from-role-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_remove-user-from-role" {
type        = "zip"
source_dir  = "cloudfunctions/remove-user-from-role"
output_path = "cloudfunctions/remove-user-from-role.zip"
}

resource "google_storage_bucket_object" "dev-remove-user-from-role-object" {
  name   = "dev-remove-user-from-role-source.zip"
  bucket = google_storage_bucket.dev-remove-user-from-role-bucket.name
  source = data.archive_file.zip_the_python_code_dev_remove-user-from-role.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-remove-user-from-role" {
  name        = "cf-dev-remove-user-from-role"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-remove-user-from-role-bucket.name
        object = google_storage_bucket_object.dev-remove-user-from-role-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-remove-user-from-role-member" {
  location = google_cloudfunctions2_function.cf-dev-remove-user-from-role.location
  service  = google_cloudfunctions2_function.cf-dev-remove-user-from-role.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-get-user-roles-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-user-roles-bucket" {
  name                        = "${random_id.dev-get-user-roles-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_get-user-roles" {
type        = "zip"
source_dir  = "cloudfunctions/get-user-roles"
output_path = "cloudfunctions/get-user-roles.zip"
}

resource "google_storage_bucket_object" "dev-get-user-roles-object" {
  name   = "dev-get-user-roles-source.zip"
  bucket = google_storage_bucket.dev-get-user-roles-bucket.name
  source = data.archive_file.zip_the_python_code_dev_get-user-roles.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-get-user-roles" {
  name        = "cf-dev-get-user-roles"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-get-user-roles-bucket.name
        object = google_storage_bucket_object.dev-get-user-roles-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-get-user-roles-member" {
  location = google_cloudfunctions2_function.cf-dev-get-user-roles.location
  service  = google_cloudfunctions2_function.cf-dev-get-user-roles.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-get-role-users-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-get-role-users-bucket" {
  name                        = "${random_id.dev-get-role-users-randomID.hex}-gcf-source"
  location                    = var.region
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_get-role-users" {
type        = "zip"
source_dir  = "cloudfunctions/get-role-users"
output_path = "cloudfunctions/get-role-users.zip"
}

resource "google_storage_bucket_object" "dev-get-role-users-object" {
  name   = "dev-get-role-users-source.zip"
  bucket = google_storage_bucket.dev-get-role-users-bucket.name
  source = data.archive_file.zip_the_python_code_dev_get-role-users.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-get-role-users" {
  name        = "cf-dev-get-role-users"
  location    = var.region

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-get-role-users-bucket.name
        object = google_storage_bucket_object.dev-get-role-users-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-get-role-users-member" {
  location = google_cloudfunctions2_function.cf-dev-get-role-users.location
  service  = google_cloudfunctions2_function.cf-dev-get-role-users.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
