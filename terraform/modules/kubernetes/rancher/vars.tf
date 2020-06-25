variable "rancher_server_url" {
  type        = string
  description = "Rancher server-url"
  default     = "my.rancher.org"
}

variable "ssh_private_key" {
  type        = string
  description = "SSH private key"
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "vm_depends_on" {
  type    = any
  default = null
}

variable "control_plane_nodes" {
  type    = list
  default = []
}

variable "worker_nodes" {
  type    = list
  default = []
}

variable "create_default_credential" {
  type    = bool
  default = true
}

variable "create_user_cluster" {
  type    = bool
  default = true
}

variable "user_cluster_name" {
  type    = string
  default = ""
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