locals {
  cluster_iam_roles = tolist(["roles/container.defaultNodeServiceAccount", "roles/artifactregistry.reader"])
  eventarc_roles = tolist(
    [
      "roles/compute.viewer",
      "roles/container.developer",
      "roles/iam.serviceAccountAdmin",
      "roles/eventarc.serviceAgent"
    ]
  )
  gke_receiver_roles = tolist(
    [
      "roles/eventarc.eventReceiver",
      "roles/pubsub.subscriber"
    ]
  )
}


resource "google_project_iam_binding" "default_node_service_account" {
  count = length(local.cluster_iam_roles)
  project = var.google_cloud_project_id
  role    = local.cluster_iam_roles[count.index]
  members = ["serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"]
}


# Creating these IAM bindings is the equivalent of running `gcloud eventarc gke-destinations init` and
# `gcloud beta services identity create --service eventarc.googleapis.com`.
resource "google_project_iam_binding" "eventarc_service_agent_gke_destinations_bindings" {
  count = length(local.eventarc_roles)
  project = var.google_cloud_project_id
  role = local.eventarc_roles[count.index]
  members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-eventarc.iam.gserviceaccount.com"]
}


# Create a service account to be used by GKE trigger.
resource "google_service_account" "eventarc_gke_trigger_service_account" {
  account_id   = "eventarc-gke-trigger-sa"
  display_name = "Evenarc GKE Trigger Service Account"
}

# Grant permission to receive Eventarc events and subscribe to Pub/Sub topics.
resource "google_project_iam_binding" "event_receiver" {
  count = length(local.gke_receiver_roles)
  project = var.google_cloud_project_id
  role    = local.gke_receiver_roles[count.index]
  members  = ["serviceAccount:${google_service_account.eventarc_gke_trigger_service_account.email}"]
}
