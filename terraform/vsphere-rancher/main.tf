terraform {
  required_version = ">= 0.12.0"
  backend "local" {
    path = "./deliverables/terraform.tfstate"
  }
}

locals { 
  control_plane_ips      = length(var.static-ip-addresses) == 0 ? [] : slice(var.static-ip-addresses, 0, var.control_plane_count)
  worker_ips             = length(var.static-ip-addresses) == 0 ? [] : slice(var.static-ip-addresses, var.control_plane_count, var.worker_count+var.control_plane_count)
}


module "control_plane" {
  source = "../modules/infrastructure/vsphere"

  node_count             = var.control_plane_count
  type                   = "control-plane"
  vm-datastore           = var.vm-datastore
  vm-name                = var.vm-name
  vm-network             = var.vm-network
  vm-template-name       = var.vm-template-name
  vsphere-datacenter     = var.vsphere-datacenter
  vsphere-password       = var.vsphere-password
  vsphere-unverified-ssl = var.vsphere-unverified-ssl
  vsphere-user           = var.vsphere-user
  vsphere-vcenter        = var.vsphere-vcenter
  vsphere-vm-folder      = var.vsphere-vm-folder
  vsphere-resource-pool  = var.vsphere-resource-pool
  ssh-public-key         = var.ssh-public-key
  static_ips             = local.control_plane_ips
}

module "worker" {
  source = "../modules/infrastructure/vsphere"

  node_count             = var.worker_count
  type                   = "worker"
  vm-datastore           = var.vm-datastore
  vm-name                = var.vm-name
  vm-network             = var.vm-network
  vm-template-name       = var.vm-template-name
  vsphere-datacenter     = var.vsphere-datacenter
  vsphere-password       = var.vsphere-password
  vsphere-unverified-ssl = var.vsphere-unverified-ssl
  vsphere-user           = var.vsphere-user
  vsphere-vcenter        = var.vsphere-vcenter
  vsphere-vm-folder      = var.vsphere-vm-folder
  vsphere-resource-pool  = var.vsphere-resource-pool
  ssh-public-key         = var.ssh-public-key
  static_ips             = local.worker_ips
}

module "rancher" {
  source = "../modules/kubernetes/rancher"

  vm_depends_on       = [module.worker.node_ips, module.control_plane.node_ips]
  control_plane_ips   = module.control_plane.node_ips
  control_plane_names = [""]
  worker_ips          = module.worker.node_ips
  worker_names        = [""]
  rancher-server-url  = var.rancher-server-url
  ssh-private-key     = var.ssh-private-key
  ssh-public-key      = var.ssh-public-key
}
