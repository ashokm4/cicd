variable "project_id" {
  type = string
}

variable "env" {
  type = string
}

variable "location" {
  type = string
}

variable "namespace" {
  type = string
}

variable "source_repo" {
  type = string
}

variable "cloudbuild_file" {
  type = string
}

variable "approval_required" {
  default = true
  type    = bool
}
