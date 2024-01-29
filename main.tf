
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



resource "google_firestore_database" "gcp-new-test-dev-users" {
  name                              = "gcp-new-test-dev-users"
  location_id                       = "nam5"
  type                              = "FIRESTORE_NATIVE"
}

resource "random_id" "gcp-new-test-Dev-Create_User-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "gcp-new-test-Dev-Create_User-bucket" {
  name                        = "${random_id.gcp-new-test-Dev-Create_User-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_Create_User" {
type        = "zip"
source_dir  = "lambdas/Create_User"
output_path = "lambdas/Create_User.zip"
}

resource "google_storage_bucket_object" "gcp-new-test-Dev-Create_User-object" {
  name   = "Dev-Create_User-source.zip"
  bucket = google_storage_bucket.gcp-new-test-Dev-Create_User-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_Create_User.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_Create_User" {
  name        = "gcp-new-test-Dev-Create_User"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.gcp-new-test-Dev-Create_User-bucket.name
        object = google_storage_bucket_object.gcp-new-test-Dev-Create_User-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_Create_User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Create_User.location
  service  = google_cloudfunctions2_function.cf_Dev_Create_User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "gcp-new-test-Dev-Get_User-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "gcp-new-test-Dev-Get_User-bucket" {
  name                        = "${random_id.gcp-new-test-Dev-Get_User-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_Get_User" {
type        = "zip"
source_dir  = "lambdas/Get_User"
output_path = "lambdas/Get_User.zip"
}

resource "google_storage_bucket_object" "gcp-new-test-Dev-Get_User-object" {
  name   = "Dev-Get_User-source.zip"
  bucket = google_storage_bucket.gcp-new-test-Dev-Get_User-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_Get_User.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_Get_User" {
  name        = "gcp-new-test-Dev-Get_User"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.gcp-new-test-Dev-Get_User-bucket.name
        object = google_storage_bucket_object.gcp-new-test-Dev-Get_User-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_Get_User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Get_User.location
  service  = google_cloudfunctions2_function.cf_Dev_Get_User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "gcp-new-test-Dev-Update_User-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "gcp-new-test-Dev-Update_User-bucket" {
  name                        = "${random_id.gcp-new-test-Dev-Update_User-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_Update_User" {
type        = "zip"
source_dir  = "lambdas/Update_User"
output_path = "lambdas/Update_User.zip"
}

resource "google_storage_bucket_object" "gcp-new-test-Dev-Update_User-object" {
  name   = "Dev-Update_User-source.zip"
  bucket = google_storage_bucket.gcp-new-test-Dev-Update_User-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_Update_User.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_Update_User" {
  name        = "gcp-new-test-Dev-Update_User"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.gcp-new-test-Dev-Update_User-bucket.name
        object = google_storage_bucket_object.gcp-new-test-Dev-Update_User-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_Update_User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Update_User.location
  service  = google_cloudfunctions2_function.cf_Dev_Update_User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "gcp-new-test-Dev-Delete_User-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "gcp-new-test-Dev-Delete_User-bucket" {
  name                        = "${random_id.gcp-new-test-Dev-Delete_User-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_Delete_User" {
type        = "zip"
source_dir  = "lambdas/Delete_User"
output_path = "lambdas/Delete_User.zip"
}

resource "google_storage_bucket_object" "gcp-new-test-Dev-Delete_User-object" {
  name   = "Dev-Delete_User-source.zip"
  bucket = google_storage_bucket.gcp-new-test-Dev-Delete_User-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_Delete_User.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_Delete_User" {
  name        = "gcp-new-test-Dev-Delete_User"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.gcp-new-test-Dev-Delete_User-bucket.name
        object = google_storage_bucket_object.gcp-new-test-Dev-Delete_User-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_Delete_User_member" {
  location = google_cloudfunctions2_function.cf_Dev_Delete_User.location
  service  = google_cloudfunctions2_function.cf_Dev_Delete_User.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "random_id" "gcp-new-test-Dev-List_Users-randomID" {
  byte_length = 8
}

resource "google_storage_bucket" "gcp-new-test-Dev-List_Users-bucket" {
  name                        = "${random_id.gcp-new-test-Dev-List_Users-randomID.hex}-gcf-source"
  location                    = "US"
  uniform_bucket_level_access = true
}

data "archive_file" "zip_the_python_code_Dev_List_Users" {
type        = "zip"
source_dir  = "lambdas/List_Users"
output_path = "lambdas/List_Users.zip"
}

resource "google_storage_bucket_object" "gcp-new-test-Dev-List_Users-object" {
  name   = "Dev-List_Users-source.zip"
  bucket = google_storage_bucket.gcp-new-test-Dev-List_Users-bucket.name
  source = data.archive_file.zip_the_python_code_Dev_List_Users.output_path # Add path to the zipped function source code
}

resource "google_cloudfunctions2_function" "cf_Dev_List_Users" {
  name        = "gcp-new-test-Dev-List_Users"
  location    = "us-west2"

  build_config {
    runtime     = "python39"
    source {
      storage_source {
        bucket = google_storage_bucket.gcp-new-test-Dev-List_Users-bucket.name
        object = google_storage_bucket_object.gcp-new-test-Dev-List_Users-object.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
  }
}

resource "google_cloud_run_service_iam_member" "Dev_List_Users_member" {
  location = google_cloudfunctions2_function.cf_Dev_List_Users.location
  service  = google_cloudfunctions2_function.cf_Dev_List_Users.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
