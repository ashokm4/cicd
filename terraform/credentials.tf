variable project_id {
   default = "ashok-bc-test"
   type  = string
}

variable env {
  default = "prod"
  type  = string
}
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}
provider "google-beta" {
  #  project     = "terraform"
  project = var.project_id
  region  = "us-central1"
}
provider "time" {
}

#resource "google_storage_bucket" "cicd-tfstate-bucket" {
#  name          = "${var.project_id}-cicd-tfstate"
#  location      = "US"
#  force_destroy = true
#
#  lifecycle_rule {
#    condition {
#      age = 3
#    }
#    action {
#      type = "Delete"
#    }
#  }
#}

#output "storage_bucket" {
# value = google_storage_bucket.cicd-tfstate-bucket.name
#}

resource "google_project_iam_member" "bucketprivilege_admin" {
  member  = "user:ashok.mahajan@bigcommerce.com"
  project = var.project_id
  role    = "roles/storage.objectAdmin"
}
#resource "google_project_iam_member" "bucketprivilege_list" {
#resource "google_storage_bucket_iam_member" "bucketprivilege_list" {
#  member  = "user:ashok.mahajan@bigcommerce.com"
#  bucket  = google_storage_bucket.cicd-tfstate-bucket.name
##  project = var.project_id
#  role    = "roles/storage.objectViewer"
#}

data "google_project" "project" {}

output "service_account" {
value = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_project_iam_member" "cloudbuild_roles" {
  depends_on = [google_cloudbuild_trigger.trigger]
  for_each   = toset(["roles/run.admin", "roles/iam.serviceAccountUser", "roles/storage.objectAdmin"])
 # for_each   = toset(["roles/run.admin"])
  project    = var.project_id
  role       = each.key
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

terraform {
  backend "gcs" {
    bucket = "ashok-bc-test-cicd-tfstate"
    prefix = "env/prod"
  }
}


locals {
  services = [
    "cloudresourcemanager.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
  ]
}
resource "google_project_service" "enabled_service" {
  for_each = toset(local.services)
  project  = var.project_id
  service  = each.key
}

