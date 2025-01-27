variable "google_cloud_project_id" {
  type = string
  default = "terraform-training-438911"
}

variable "google_cloud_region" {
  type = string
  default = "europe-west1"
}

variable "github_organisation" {
  type = string
  default = "octue"
}

variable "service_account_names" {
  type = set(string)
  default = ["cortadocodes", "thclark"]
}

variable "google_cloud_credentials_file" {
  type    = string
  default = "gcp-credentials.json"
}

variable "deletion_protection" {
  type    = bool
  default = false
}
