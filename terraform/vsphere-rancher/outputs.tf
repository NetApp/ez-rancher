output "control_plane_ips" {
  value = module.control_plane.node_ips
}

output "worker_ips" {
  value = module.worker.node_ips
}