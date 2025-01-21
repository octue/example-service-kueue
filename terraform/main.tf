terraform {
  required_version = ">= 1.8.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>6.12"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~>2.35.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~>1.19.0"
    }
  }

  cloud {
    organization = "octue"
    workspaces {
      project = "octue-sdk-python"
      tags = ["example-service-kueue"]
    }
  }
}


provider "google" {
  credentials = file(var.google_cloud_credentials_file)
  project     = var.google_cloud_project_id
  region      = var.google_cloud_region
}


data "google_client_config" "default" {}


provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}


provider "kubectl" {
  load_config_file       = false
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}


module "octue_twined" {
  source = "git::github.com/octue/terraform-octue-twined.git?ref=create-initial-module"

  google_cloud_project_id = var.google_cloud_project_id
  google_cloud_project_number = var.google_cloud_project_number
  google_cloud_region = var.google_cloud_region
  github_organisation = var.github_organisation
  environment = terraform.workspace
  twined_service_namespace = var.twined_service_namespace
  service_account_names = var.service_account_names
  deletion_protection = var.deletion_protection
}
