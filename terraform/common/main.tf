locals {
  project_id    = "your_project"
  location      = "us-central1"
  namespace     = "devops"
  account_owner = "account.owner@gmail.com"
  services = [
      "cloudresourcemanager.googleapis.com",
      "sourcerepo.googleapis.com",
      "cloudbuild.googleapis.com",
      "run.googleapis.com",
      "iam.googleapis.com",
      "compute.googleapis.com",
    ]
  }

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.location
}
provider "google-beta" {
  #  project     = "terraform"
  project = local.project_id
  region  = var.location
}
provider "time" {
}


resource "google_project_service" "enabled_service" {
  for_each = toset(local.services)
  project  = local.project_id
  service  = each.key
}

resource "google_storage_bucket" "tfstate-bucket" {
  name          = "${local.project_id}-${local.namespace}-tfstate"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_project_iam_member" "bucketprivilege_viewer" {
  member  = "user:${local.account_owner}"
  project = local.project_id
  role = "roles/storage.objectViewer"
}

data "google_project" "project" {}


resource "google_project_iam_member" "cloudbuild_roles" {
  for_each   = toset(["roles/run.admin", "roles/iam.serviceAccountUser", "roles/storage.objectAdmin"])
  project    = local.project_id
  role       = each.key
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_sourcerepo_repository" "repo" {
  depends_on = [
    google_project_service.enabled_service["sourcerepo.googleapis.com"]
  ]
  name = "${local.project_id}-${local.namespace}-repo"
}
