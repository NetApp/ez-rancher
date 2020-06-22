output "control_plane_ips" {
  value = module.control_plane.node_ips
}

output "worker_ips" {
  value = module.worker.node_ips
}

output "control_plane_nodes" {
  value = module.control_plane.nodes
}

output "worker_nodes" {
  value = module.worker.nodes
}