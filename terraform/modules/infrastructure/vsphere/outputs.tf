locals {
  node_ips_no_mask = split("\n", replace(join("\n", var.static_ips),"/\\/.*/", ""))
}

output "node_ips" {
  value = "${local.num_addresses == 0 ? vsphere_virtual_machine.node[*].default_ip_address : local.node_ips_no_mask}"
}