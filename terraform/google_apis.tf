resource "google_project_service" "gke_api" {
  service = "container.googleapis.com"
  disable_dependent_services = true
  project = var.google_cloud_project_id
}


resource "time_sleep" "wait_for_google_apis_to_enable" {
  depends_on = [google_project_service.gke_api]
  create_duration = "1m"
}
