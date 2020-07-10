output "cluster_nodes" {
  value = module.cluster_nodes.nodes
}

output "rancher_server_url" {
  value = join("", ["https://", module.rancher.rancher_server_url])
}