terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

locals {
  project_name = "lab-k8s"
}

data "digitalocean_kubernetes_versions" "this" {

}

resource "digitalocean_kubernetes_cluster" "this" {
  name    = "${local.project_name}-cluster"
  region  = "nyc1"
  version = data.digitalocean_kubernetes_versions.this.latest_version

  node_pool {
    name       = "pool-worker-nodes"
    size       = "s-2vcpu-4gb" # Necessário para rodar o helm prometheus + grafana
    node_count = 2
  }
}

resource "local_file" "kubeconfig" {
  content  = digitalocean_kubernetes_cluster.this.kube_config[0].raw_config
  filename = "${path.module}/kubeconfig-do.yaml"
}

output "cluster_id" {
  value = digitalocean_kubernetes_cluster.this.id
}
