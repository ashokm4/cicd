resource "google_cloudbuild_trigger" "trigger" {
  name     = "${var.namespace}-${var.env}"
  location = var.location
  trigger_template {
    branch_name = var.env
    repo_name   = var.source_repo
  }
  filename = var.cloudbuild_file
  approval_config {
      approval_required = true
  }

}

output "trigger_details" {
  value = google_cloudbuild_trigger.trigger
}
