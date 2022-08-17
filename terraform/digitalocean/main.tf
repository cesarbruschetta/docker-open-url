terraform {
  required_version = ">= 1.1.8"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.7.0"
    }
  }

}

provider "kubernetes" {
  host             = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
  token            = digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.k8s_cluster.kube_config[0].cluster_ca_certificate
  )
}

# Deploy the actual Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "k8s_cluster" {
  name    = "${var.env}-${var.application}"
  region  = var.region
  version = "1.23.9-do.0"

  tags = [var.env]

  # This default node pool is mandatory
  node_pool {
    name       = "default-pool-${var.env}-${var.application}"
    size       = "m-4vcpu-32gb" # list available options with `doctl compute size list`
    auto_scale = true
    node_count = 2
    min_nodes = 1
    max_nodes = 10
    tags       = ["node-pool-${var.env}"]
  }

}

# Deploy aplication in the Kubernetes cluster
resource "kubernetes_namespace" "app" {
  metadata {
    name = "${var.env}-${var.application}"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "${var.env}-${var.application}"
    namespace= kubernetes_namespace.app.metadata.0.name
  }
  spec {
    replicas = "${var.count_replicas}"
    selector {
      match_labels = {
        app = "${var.env}-${var.application}"
      }
    }
    template {
      metadata {
        labels = {
          app  = "${var.env}-${var.application}"
        }
      }
      spec {
        volume {
          name = "dshm"
          empty_dir {
            medium = "Memory"
            size_limit = 2048 # 2GB
          }
        }
        container {
          image = "ghcr.io/cesarbruschetta/docker-open-url:latest"
          name  = "${var.env}-${var.application}"
          resources {
            limits = {
              memory = "1G"
              cpu = "1"
            }
            requests = {
              memory = "512M"
              cpu = "512m"
            }
          }
          env {
            name  = "FIREFOX_URL"
            value = "${var.open_browser_url}"
          }
          port {
            container_port = 5800
          }
          volume_mount {
            name = "dshm"
            mount_path = "/dev/shm"
          }
        }
      }
    }
  }
}
