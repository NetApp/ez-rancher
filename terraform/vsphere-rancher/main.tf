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
  vm_cpu                 = var.vm_cpu
  vm_ram                 = var.vm_ram
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
  dns_servers            = var.dns_servers
}

module "worker" {
  source = "../modules/infrastructure/vsphere"

  node_count             = var.worker_count
  type                   = "worker"
  vm_datastore           = var.vm_datastore
  vm_name                = var.vm_name
  vm_network             = var.vm_network
  vm_cpu                 = var.vm_cpu
  vm_ram                 = var.vm_ram
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
  dns_servers            = var.dns_servers
}

module "rancher" {
  source = "../modules/kubernetes/rancher"

  vm_depends_on       = [module.worker.nodes, module.control_plane.nodes]
  control_plane_nodes = module.control_plane.nodes
  worker_nodes        = module.worker.nodes
  rancher_server_url  = var.rancher_server_url
  ssh_private_key     = var.ssh_private_key
  ssh_public_key      = var.ssh_public_key

  create_user_cluster = true
  user_cluster_name   = "sg-test"

  rancher_vsphere_username = var.vsphere_user
  rancher_vsphere_password = var.vsphere_password
  #rancher_vsphere_server =  var.vsphere_vcenter
  rancher_vsphere_server =  "10.193.136.5" # TODO figure out why Rancher cant resolve vcenter
  rancher_vsphere_port = 443

  rancher_vsphere_datacenter = var.vsphere_datacenter
  rancher_vsphere_datastore  = var.vm_datastore
  rancher_vsphere_folder     = var.vsphere_vm_folder
  rancher_vsphere_network    = var.vm_network
  rancher_vsphere_pool       = var.vsphere_resource_pool
}
