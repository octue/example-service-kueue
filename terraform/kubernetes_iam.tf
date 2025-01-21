resource "google_project_iam_binding" "default_node_service_account" {
  project = var.google_cloud_project_id
  role    = "roles/container.defaultNodeServiceAccount"
  members = ["serviceAccount:${var.google_cloud_project_number}-compute@developer.gserviceaccount.com"]
}
