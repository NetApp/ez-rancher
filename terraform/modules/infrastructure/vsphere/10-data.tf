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

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

locals {
  num_addresses = length(var.static_ip_addresses)
  proxy_set     = var.http_proxy != "" && var.https_proxy != "" ? true : false
}

data "template_file" "metadata" {
  count    = var.node_count
  template = file("${path.module}/cloudinit/templates/metadata.tpl")
  vars = {
    hostname = format("${var.vm_name}-${var.type}%02d", count.index + 1)
    netplan  = data.template_file.netplan[count.index].rendered
  }
}

data "template_file" "kickstart_userdata" {
  count    = var.node_count
  template = file("${path.module}/cloudinit/kickstart-userdata.yaml")
  vars = {
    ssh_public_key          = tls_private_key.key.public_key_openssh
    admin_access_public_key = var.ssh_public_key
    netplan                 = base64encode(data.template_file.netplan[count.index].rendered)
    env_proxy               = local.proxy_set ? format("export http_proxy=%s https_proxy=%s", var.http_proxy, var.https_proxy) : "echo"
    docker_proxy = local.proxy_set ? base64encode(format(
    "[Service]\nEnvironment=\"HTTP_PROXY=%s\"\nEnvironment=\"HTTPS_PROXY=%s\"", var.http_proxy, var.https_proxy)) : ""
    vmware_guestinfo_ver = var.cloud_init_vmware_guestinfo_version
  }
}

data "template_file" "netplan" {
  count    = var.node_count
  template = file("${path.module}/cloudinit/templates/netplan.tpl")
  vars = {
    dhcp_enabled = local.num_addresses == 0
    dns_servers  = format("%s [%s]", "addresses:", join(",", var.dns_servers))
    addresses    = local.num_addresses > 0 ? format("%s %s", "addresses:", jsonencode([var.static_ip_addresses[count.index]])) : ""
    gateway      = var.default_gateway != "" ? format("%s %s", "gateway4:", var.default_gateway) : ""
  }
}

data "template_file" "userdata" {
  template = file("${path.module}/cloudinit/userdata.yaml")
  vars = {
    env_proxy      = local.proxy_set ? format("export http_proxy=%s https_proxy=%s", var.http_proxy, var.https_proxy) : "echo"
    docker_version = var.docker_version
  }
}
