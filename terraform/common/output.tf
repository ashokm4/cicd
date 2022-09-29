#Create storage bucket for terraform state
output "storage_bucket" {
  value = google_storage_bucket.tfstate-bucket.name
}
output "service_account" {
  value = "${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
output "source_repo" {
  value = google_sourcerepo_repository.repo.name
}
