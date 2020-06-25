output "control_plane_nodes" {
  value = module.control_plane.nodes
}

output "worker_nodes" {
  value = module.worker.nodes
}

output "rancher_server_url" {
  value = join("", ["https://", module.rancher.rancher_server_url])
}