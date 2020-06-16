output "node_ips" {
  value = vsphere_virtual_machine.node[*].default_ip_address
}