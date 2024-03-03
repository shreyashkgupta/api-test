
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



resource "google_firestore_database" "dev-user" {
  name                              = "dev-user"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "google_firestore_database" "dev-user-role-assignment" {
  name                              = "dev-user-role-assignment"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "google_firestore_database" "dev-role" {
  name                              = "dev-role"
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

resource "random_id" "dev-create-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-create-role-bucket" {
  name                        = "${random_id.dev-create-role-randomID.hex}-gcf-source"
  location                    = "US"
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
  location    = "us-west2"

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
  location                    = "US"
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
  location    = "us-west2"

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
  location                    = "US"
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
  location    = "us-west2"

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
  location                    = "US"
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
  location    = "us-west2"

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

resource "random_id" "dev-assign-role-to-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-assign-role-to-user-bucket" {
  name                        = "${random_id.dev-assign-role-to-user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_assign-role-to-user" {
type        = "zip"
source_dir  = "cloudfunctions/assign-role-to-user"
output_path = "cloudfunctions/assign-role-to-user.zip"
}

resource "google_storage_bucket_object" "dev-assign-role-to-user-object" {
  name   = "dev-assign-role-to-user-source.zip"
  bucket = google_storage_bucket.dev-assign-role-to-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_assign-role-to-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-assign-role-to-user" {
  name        = "cf-dev-assign-role-to-user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-assign-role-to-user-bucket.name
        object = google_storage_bucket_object.dev-assign-role-to-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-assign-role-to-user-member" {
  location = google_cloudfunctions2_function.cf-dev-assign-role-to-user.location
  service  = google_cloudfunctions2_function.cf-dev-assign-role-to-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-remove-role-from-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-remove-role-from-user-bucket" {
  name                        = "${random_id.dev-remove-role-from-user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_remove-role-from-user" {
type        = "zip"
source_dir  = "cloudfunctions/remove-role-from-user"
output_path = "cloudfunctions/remove-role-from-user.zip"
}

resource "google_storage_bucket_object" "dev-remove-role-from-user-object" {
  name   = "dev-remove-role-from-user-source.zip"
  bucket = google_storage_bucket.dev-remove-role-from-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_remove-role-from-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-remove-role-from-user" {
  name        = "cf-dev-remove-role-from-user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-remove-role-from-user-bucket.name
        object = google_storage_bucket_object.dev-remove-role-from-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-remove-role-from-user-member" {
  location = google_cloudfunctions2_function.cf-dev-remove-role-from-user.location
  service  = google_cloudfunctions2_function.cf-dev-remove-role-from-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-list-roles-for-user-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-list-roles-for-user-bucket" {
  name                        = "${random_id.dev-list-roles-for-user-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_list-roles-for-user" {
type        = "zip"
source_dir  = "cloudfunctions/list-roles-for-user"
output_path = "cloudfunctions/list-roles-for-user.zip"
}

resource "google_storage_bucket_object" "dev-list-roles-for-user-object" {
  name   = "dev-list-roles-for-user-source.zip"
  bucket = google_storage_bucket.dev-list-roles-for-user-bucket.name
  source = data.archive_file.zip_the_python_code_dev_list-roles-for-user.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-list-roles-for-user" {
  name        = "cf-dev-list-roles-for-user"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-list-roles-for-user-bucket.name
        object = google_storage_bucket_object.dev-list-roles-for-user-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-list-roles-for-user-member" {
  location = google_cloudfunctions2_function.cf-dev-list-roles-for-user.location
  service  = google_cloudfunctions2_function.cf-dev-list-roles-for-user.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "dev-list-users-for-role-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "dev-list-users-for-role-bucket" {
  name                        = "${random_id.dev-list-users-for-role-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_dev_list-users-for-role" {
type        = "zip"
source_dir  = "cloudfunctions/list-users-for-role"
output_path = "cloudfunctions/list-users-for-role.zip"
}

resource "google_storage_bucket_object" "dev-list-users-for-role-object" {
  name   = "dev-list-users-for-role-source.zip"
  bucket = google_storage_bucket.dev-list-users-for-role-bucket.name
  source = data.archive_file.zip_the_python_code_dev_list-users-for-role.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf-dev-list-users-for-role" {
  name        = "cf-dev-list-users-for-role"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.dev-list-users-for-role-bucket.name
        object = google_storage_bucket_object.dev-list-users-for-role-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "dev-list-users-for-role-member" {
  location = google_cloudfunctions2_function.cf-dev-list-users-for-role.location
  service  = google_cloudfunctions2_function.cf-dev-list-users-for-role.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
