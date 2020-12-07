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
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "VMware vSphere password"
  sensitive   = true
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
  default     = "2"
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

variable "vm_hardware_version" {
  type        = number
  description = "The VM hardware version number"
  default     = null
}

variable "static_ip_addresses" {
  type        = list(any)
  description = "List of IP addresses"
  default     = []
}

variable "default_gateway" {
  type        = string
  description = "Default Gateway"
  default     = ""
}

variable "dns_servers" {
  type        = list(any)
  description = "List of DNS server IPv4 addresses"
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
  default     = ""
}

variable "http_proxy" {
  type    = string
  default = ""
}

variable "https_proxy" {
  type    = string
  default = ""
}

variable "no_proxy" {
  type    = string
  default = ""
}

# https://github.com/vmware/cloud-init-vmware-guestinfo/releases
variable "cloud_init_vmware_guestinfo_version" {
  type    = string
  default = "master"
}

# https://github.com/rancher/install-docker
variable "docker_version" {
  type    = string
  default = "19.03.13"
}
