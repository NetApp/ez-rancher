data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  num_addresses = length(var.static_ip_addresses)
}

data "template_file" "metadata" {
  count    = var.node_count
  template = "${file("${path.module}/cloudinit/templates/metadata.tpl")}"
  vars = {
    ssh_public_key = file(var.ssh_public_key)
    hostname       = format("${var.vm_name}-${var.type}%02d", count.index + 1)
    addresses_key  = local.num_addresses > 0 ? "addresses: " : ""
    addresses_val  = local.num_addresses > 0 ? jsonencode([var.static_ip_addresses[count.index]]) : ""
    gateway        = var.default_gateway != "" ? format("%s %s", "gateway4:", var.default_gateway) : ""
    dns_servers    = format("%s [%s]", "addresses:", join(",", var.dns_servers))
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/cloudinit/userdata2.yaml")}"
  vars = {
    ssh_public_key = file(var.ssh_public_key)
  }
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}
