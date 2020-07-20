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
  type    = list
  default = []
}

variable "bootstrap_rancher" {
  type    = bool
  default = false
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

variable "rancher_node_template_disk_size" {
  type    = number
  default = 51200
}
