terraform {
  required_version = ">= 0.12.0"
  backend "local" {
    path = "./deliverables/terraform.tfstate"
  }
}

locals {
  control_plane_ips = length(var.static_ip_addresses) == 0 ? [] : slice(var.static_ip_addresses, 0, var.control_plane_count)
  worker_ips        = length(var.static_ip_addresses) == 0 ? [] : slice(var.static_ip_addresses, var.control_plane_count, var.worker_count + var.control_plane_count)
}


module "control_plane" {
  source = "../modules/infrastructure/vsphere"

  node_count             = var.control_plane_count
  type                   = "control-plane"
  vm_datastore           = var.vm_datastore
  vm_name                = var.vm_name
  vm_network             = var.vm_network
  vm_template_name       = var.vm_template_name
  vsphere_datacenter     = var.vsphere_datacenter
  vsphere_password       = var.vsphere_password
  vsphere_unverified_ssl = var.vsphere_unverified_ssl
  vsphere_user           = var.vsphere_user
  vsphere_vcenter        = var.vsphere_vcenter
  vsphere_vm_folder      = var.vsphere_vm_folder
  vsphere_resource_pool  = var.vsphere_resource_pool
  ssh_public_key         = var.ssh_public_key
  static_ip_addresses    = local.control_plane_ips
  default_gateway        = var.default_gateway
}

module "worker" {
  source = "../modules/infrastructure/vsphere"

  node_count             = var.worker_count
  type                   = "worker"
  vm_datastore           = var.vm_datastore
  vm_name                = var.vm_name
  vm_network             = var.vm_network
  vm_template_name       = var.vm_template_name
  vsphere_datacenter     = var.vsphere_datacenter
  vsphere_password       = var.vsphere_password
  vsphere_unverified_ssl = var.vsphere_unverified_ssl
  vsphere_user           = var.vsphere_user
  vsphere_vcenter        = var.vsphere_vcenter
  vsphere_vm_folder      = var.vsphere_vm_folder
  vsphere_resource_pool  = var.vsphere_resource_pool
  ssh_public_key         = var.ssh_public_key
  static_ip_addresses    = local.worker_ips
  default_gateway        = var.default_gateway
}

module "rancher" {
  source = "../modules/kubernetes/rancher"

  vm_depends_on       = [module.worker.node_ips, module.control_plane.node_ips]
  control_plane_ips   = module.control_plane.node_ips
  control_plane_names = [""]
  worker_ips          = module.worker.node_ips
  worker_names        = [""]
  rancher_server_url  = var.rancher_server_url
  ssh_private_key     = var.ssh_private_key
  ssh_public_key      = var.ssh_public_key
}
