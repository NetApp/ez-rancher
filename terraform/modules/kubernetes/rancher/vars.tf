variable "rancher_server_url" {
  type        = string
  description = "Rancher server-url"
  default     = "my.rancher.org"
}

variable "rancher_password" {
  type    = string
  default = "solidfire"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key"
}

variable "vm_depends_on" {
  type    = any
  default = null
}

variable "deliverables_path" {
  type        = string
  description = "Path to deliverables directory"
  default     = "./deliverables"
}

variable "cluster_nodes" {
  type    = list(any)
  default = []
}

variable "rancher_create_trident_catalog" {
  type    = bool
  default = true
}

variable "rancher_trident_installer_branch" {
  type    = string
  default = "master"
}

variable "rancher_create_node_template" {
  type    = bool
  default = false
}

variable "rancher_node_template_name" {
  type    = string
  default = "vsphere-default"
}

variable "create_user_cluster" {
  type    = bool
  default = true
}

variable "user_cluster_name" {
  type    = string
  default = ""
}

variable "user_cluster_cpu" {
  type    = string
  default = 2
}

variable "user_cluster_memoryMB" {
  type    = string
  default = 6144
}

variable "rancher_vsphere_username" {
  type    = string
  default = ""
}

variable "rancher_vsphere_password" {
  type    = string
  default = ""
}

variable "rancher_vsphere_server" {
  type    = string
  default = ""
}

variable "rancher_vsphere_port" {
  type    = string
  default = 443
}

variable "rancher_vsphere_datacenter" {
  type    = string
  default = ""
}

variable "rancher_vsphere_datastore" {
  type    = string
  default = ""
}

variable "rancher_vsphere_folder" {
  type    = string
  default = ""
}

variable "rancher_vsphere_network" {
  type    = string
  default = ""
}

variable "rancher_vsphere_pool" {
  type    = string
  default = ""
}

variable "rancher_vm_template_name" {
  type    = string
  default = ""
}

variable "rancher_node_template_disk_size" {
  type    = number
  default = 51200
}

variable "http_proxy" {
  type    = string
  default = ""
}

variable "no_proxy" {
  type    = string
  default = "127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,.svc,.cluster.local"
}

variable "rancher_cluster_cidr" {
  type    = string
  default = "10.42.0.0/16"
}

variable "rancher_service_cidr" {
  type    = string
  default = "10.43.0.0/16"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "rancher_version" {
  type    = string
  default = ""
}
