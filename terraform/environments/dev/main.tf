locals {
  project_id      = "your_project"
  location        = "us-central1"
  namespace       = "devops"
  cloudbuild_file = "cloudbuild.yaml"
  env             = "dev"
  source_repo     = "${local.project_id}-${local.namespace}-repo"
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
  project = local.project_id
  region  = var.location
}

terraform {
  backend "gcs" {
    bucket = "${local.project_id}-${local.namespace}-repo"
    prefix = "env/dev"
  }
}

module "build_trigger_dev" {
  source          = "../../modules/build_trigger"
  project_id      = local.project_id
  location        = local.location
  namespace       = local.namespace
  env             = local.env
  source_repo     = local.source_repo
  cloudbuild_file = local.cloudbuild_file
}
