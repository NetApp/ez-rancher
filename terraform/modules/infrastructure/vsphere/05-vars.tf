variable "node_count" {
  type        = number
  description = "Number of nodes"
}

variable "type" {
  type        = string
  description = "Type of nodes"
}

variable "vsphere_user" {
  type        = string
  description = "VMware vSphere user name"
}

variable "vsphere_password" {
  type        = string
  description = "VMware vSphere password"
}

variable "vsphere_vcenter" {
  type        = string
  description = "VMWare vCenter server FQDN / IP"
}

variable "vsphere_resource_pool" {
  type        = string
  description = "VMWare vSphere resource pool"
  default     = ""
}

variable "vsphere_unverified_ssl" {
  type        = string
  description = "Is the VMware vCenter using a self signed certificate (true/false)"
}

variable "vsphere_datacenter" {
  type        = string
  description = "VMWare vSphere datacenter"
}

variable "vsphere_vm_folder" {
  type        = string
  description = "VM folder to create vms under"
  default     = ""
}

variable "vsphere_template_folder" {
  type        = string
  description = "Template folder"
  default     = "Templates"
}

variable "vm_datastore" {
  type        = string
  description = "Datastore used for the vSphere virtual machines"
}

variable "vm_network" {
  type        = string
  description = "Network used for the vSphere virtual machines"
}

variable "vm_cpu" {
  type        = string
  description = "Number of vCPU for the vSphere virtual machines"
  default     = "4"
}

variable "vm_ram" {
  type        = string
  default     = 8192
  description = "Amount of memory for virtual machines (example: 2048)"
}

variable "vm_name" {
  type        = string
  description = "The name to assign to the machines"
}

variable "vm_template_name" {
  type        = string
  description = "The template to clone to create the VM"
}

variable "vm_domain" {
  type        = string
  description = "Domain name for the machine."
  default     = ""
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

variable "static_ip_addresses" {
  type        = list
  description = "List of IP addresses"
  default     = []
}

variable "default_gateway" {
  type        = string
  description = "Default Gateway"
  default     = ""
}

variable "dns_servers" {
  type        = list
  description = "List of DNS server IPv4 addresses"
  default     = ["1.1.1.1", "8.8.8.8"]
}