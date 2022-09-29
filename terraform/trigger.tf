#resource "google_sourcerepo_repository" "repo" {
#  depends_on = [
#    google_project_service.enabled_service["sourcerepo.googleapis.com"]
#  ]
#name       = "${var.project_id}-cicd-repo"
#}

resource "google_cloudbuild_trigger" "trigger" {
  name = "cicd-test-${var.env}"
  location  = "us-central1"
  depends_on = [
    google_project_service.enabled_service["cloudbuild.googleapis.com"]
  ]
trigger_template {
    branch_name = var.env
    repo_name   = "ashok-bc-test-cicd-repo" 
  }
filename = "cloudbuild.yaml"
}

output trigger_details {
  value = google_cloudbuild_trigger.trigger
}
