variable "node_count" {
  type        = number
  description = "Number of nodes"
}

variable "type" {
  type        = string
  description = "Type of nodes"
}

variable "vsphere-user" {
  type        = string
  description = "VMware vSphere user name"
}

variable "vsphere-password" {
  type        = string
  description = "VMware vSphere password"
}

variable "vsphere-vcenter" {
  type        = string
  description = "VMWare vCenter server FQDN / IP"
}

variable "vsphere-resource-pool" {
  type        = string
  description = "VMWare vSphere resource pool"
  default     = "*/Resources"
}

variable "vsphere-unverified-ssl" {
  type        = string
  description = "Is the VMware vCenter using a self signed certificate (true/false)"
}

variable "vsphere-datacenter" {
  type        = string
  description = "VMWare vSphere datacenter"
}

variable "vsphere-vm-folder" {
  type        = string
  description = "VM folder to create vms under"
  default     = ""
}

variable "vsphere-template-folder" {
  type        = string
  description = "Template folder"
  default     = "Templates"
}

variable "vm-count" {
  type        = string
  description = "Number of VM"
  default     = 3
}

variable "vm-name-prefix" {
  type        = string
  description = "Name of VM prefix"
  default     = "ezvsphere"
}

variable "vm-datastore" {
  type        = string
  description = "Datastore used for the vSphere virtual machines"
}

variable "vm-network" {
  type        = string
  description = "Network used for the vSphere virtual machines"
}

variable "vm-linked-clone" {
  type        = string
  description = "Use linked clones"
  default     = "false"
}

variable "vm-cpu" {
  type        = string
  description = "Number of vCPU for the vSphere virtual machines"
  default     = "4"
}

variable "vm-ram" {
  type        = string
  default     = 8192
  description = "Amount of memory for virtual machines (example: 2048)"
}

variable "vm-name" {
  type        = string
  description = "The name to assign to the machines"
}

variable "vm-template-name" {
  type        = string
  description = "The template to clone to create the VM"
}

variable "vm-domain" {
  type        = string
  description = "Domain name for the machine."
  default     = ""
}

variable "ssh-private-key" {
  type        = string
  description = "SSH private key"
  default     = "~/.ssh/id_rsa"
}

variable "ssh-public-key" {
  type        = string
  description = "SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}
