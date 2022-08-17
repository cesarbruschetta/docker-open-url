
output "k8s_endpoint" {
  value = digitalocean_kubernetes_cluster.k8s_cluster.endpoint
}