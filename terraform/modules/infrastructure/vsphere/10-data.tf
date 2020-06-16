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
