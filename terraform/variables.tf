variable "google_cloud_project_id" {
  type = string
  default = "terraform-training-438911"
}

variable "google_cloud_project_number" {
  type = string
  default = "1032632085173"
}

variable "google_cloud_region" {
  type = string
  default = "europe-west1"
}

variable "github_organisation" {
  type = string
  default = "octue"
}

variable "twined_service_namespace" {
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

variable "kueue_version" {
  type = string
  default = "v0.10.1"
}

variable "cpus" {
  type = number
  default = 2
}

variable "memory" {
  type = string
  default = "2Gi"
}
