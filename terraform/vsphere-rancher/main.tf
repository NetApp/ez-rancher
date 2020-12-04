terraform {
  required_version = ">= 0.14.0"
  backend "local" {
    path = "./deliverables/terraform.tfstate"
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_vcenter
  allow_unverified_ssl = var.vsphere_unverified_ssl
}

module "cluster_nodes" {
  source = "../modules/infrastructure/vsphere"

  node_count             = var.cluster_node_count
  type                   = "node"
  vm_datastore           = var.vm_datastore
  vm_name                = var.vm_name
  vm_network             = var.vm_network
  vm_cpu                 = var.vm_cpu
  vm_ram                 = var.vm_ram
  vm_template_name       = var.vm_template_name
  vm_hardware_version    = var.vm_hardware_version
  vsphere_datacenter     = var.vsphere_datacenter
  vsphere_password       = var.vsphere_password
  vsphere_unverified_ssl = var.vsphere_unverified_ssl
  vsphere_user           = var.vsphere_user
  vsphere_vcenter        = var.vsphere_vcenter
  vsphere_vm_folder      = var.vsphere_vm_folder
  vsphere_resource_pool  = var.vsphere_resource_pool
  static_ip_addresses    = var.static_ip_addresses
  default_gateway        = var.default_gateway
  dns_servers            = var.dns_servers
  ssh_public_key         = var.ssh_public_key
  http_proxy             = var.http_proxy
  https_proxy            = var.https_proxy
  no_proxy               = var.no_proxy
}

module "rancher" {
  source = "../modules/kubernetes/rancher"

  vm_depends_on      = [module.cluster_nodes.nodes]
  cluster_nodes      = module.cluster_nodes.nodes
  rancher_server_url = var.use_auto_dns_url ? join("", [module.cluster_nodes.nodes[0].ip, ".nip.io"]) : var.rancher_server_url
  ssh_private_key    = module.cluster_nodes.ssh_private_key
  ssh_public_key     = module.cluster_nodes.ssh_public_key
  deliverables_path  = var.deliverables_path

  rancher_password    = var.rancher_password
  create_user_cluster = var.rancher_create_user_cluster
  user_cluster_name   = var.rancher_user_cluster_name

  rancher_vsphere_username = var.vsphere_user
  rancher_vsphere_password = var.vsphere_password
  rancher_vsphere_server   = var.vsphere_vcenter
  rancher_vsphere_port     = 443

  rancher_vsphere_datacenter       = var.vsphere_datacenter
  rancher_vsphere_datastore        = var.vm_datastore
  rancher_vsphere_folder           = var.vsphere_vm_folder
  rancher_vsphere_network          = var.vm_network
  rancher_vsphere_pool             = var.vsphere_resource_pool
  rancher_vm_template_name         = var.vm_template_name
  rancher_create_node_template     = var.rancher_create_node_template
  rancher_node_template_name       = var.rancher_node_template_name
  rancher_create_trident_catalog   = var.rancher_create_trident_catalog
  rancher_trident_installer_branch = var.rancher_trident_installer_branch
  http_proxy                       = var.http_proxy
  no_proxy                         = var.no_proxy
  rancher_cluster_cidr             = var.rancher_cluster_cidr
  rancher_service_cidr             = var.rancher_service_cidr
  kubernetes_version               = var.kubernetes_version
  rancher_version                  = var.rancher_version
}
