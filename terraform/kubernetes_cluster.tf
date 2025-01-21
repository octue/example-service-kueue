resource "google_container_cluster" "primary" {
  name     = "${terraform.workspace}-cluster"
  location = var.google_cloud_region
  enable_autopilot = true
  deletion_protection = var.deletion_protection
  depends_on = [time_sleep.wait_for_google_apis_to_enable, google_project_iam_binding.default_node_service_account]
}


resource "time_sleep" "wait_for_cluster_to_be_ready" {
  depends_on = [google_container_cluster.primary]
  create_duration = "2m"
}
