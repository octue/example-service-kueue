resource "google_container_cluster" "primary" {
  name     = "${terraform.workspace}-cluster"
  location = var.google_cloud_region

  # We can't create a cluster with no node pool defined, but we want to only use separately managed node pools. So we
  # create the smallest possible default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection = var.deletion_protection
  depends_on = [time_sleep.wait_for_google_apis_to_enable]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${terraform.workspace}-node-pool"
  location   = var.google_cloud_region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    # # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # service_account = google_service_account.default.email
    # oauth_scopes    = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    # ]
  }
}
