data "vsphere_datacenter" "dc" {
  name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.vm-datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm-network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm-template-name
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  num_addresses = length(var.static-ip-addresses)
}

data "template_file" "metadata" {
  count    = var.node_count
  template = "${file("${path.module}/cloudinit/templates/metadata.tpl")}"
  vars = {
    ssh_public_key = file(var.ssh-public-key)
    hostname       = format("${var.vm-name}-${var.type}%02d", count.index + 1)
    addresses_key  = local.num_addresses > 0 ? "addresses: " : ""
    addresses_val  = local.num_addresses > 0 ? jsonencode([var.static-ip-addresses[count.index]]) : ""
    gateway        = var.default-gateway != "" ? format("%s %s", "gateway4:", var.default-gateway) : ""
  }
}

data "template_file" "userdata" {
  template = "${file("${path.module}/cloudinit/userdata2.yaml")}"
  vars = {
    ssh_public_key = file(var.ssh-public-key)
  }
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere-resource-pool
  datacenter_id = data.vsphere_datacenter.dc.id
}
