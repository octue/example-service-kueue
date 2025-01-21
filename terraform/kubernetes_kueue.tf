# Get the Kueue installation manifests.
data "http" "kueue_installation_manifests" {
  url = "https://github.com/kubernetes-sigs/kueue/releases/download/${var.kueue_version}/manifests.yaml"
}


# Split the multi-document YAML manifest into separate manifests.
locals {
  kueue_manifests = provider::kubernetes::manifest_decode_multi(data.http.kueue_installation_manifests.response_body)
}


# Install Kueue on the cluster by applying the installation manifests.
resource "kubectl_manifest" "install_kueue" {
  for_each = {
    for manifest in local.kueue_manifests :
    "${manifest.kind}--${manifest.metadata.name}" => manifest
  }
  yaml_body = yamlencode(each.value)
  server_side_apply = true
  depends_on = [time_sleep.wait_for_cluster_to_be_ready]
}


resource "time_sleep" "wait_for_kueue_installation" {
  depends_on = [kubectl_manifest.install_kueue]
  create_duration = "3m"
}


data "kubectl_path_documents" "kueue_resources" {
  pattern = "./kueue_manifests/*.yaml"
  vars = {
    cpus = var.cpus
    memory = var.memory
  }
}


resource "kubectl_manifest" "create_kueue_resources" {
    for_each  = data.kubectl_path_documents.kueue_resources.manifests
    yaml_body = each.value
    server_side_apply = true
    depends_on = [time_sleep.wait_for_kueue_installation]
}
