variable "cluster_node_count" {
  type        = number
  description = "Number of cluster nodes"
  default     = 3
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
  default     = "Resources"
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

variable "rancher_server_url" {
  type        = string
  description = "Rancher server-url"
  default     = "my.rancher.org"
}

variable "rancher_password" {
  type      = string
  default   = "solidfire"
  sensitive = true
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key"
  default     = ""
}

variable "static_ip_addresses" {
  type        = list(any)
  description = "List of IP addresses"
  default     = []
}

variable "default_gateway" {
  type        = string
  description = "Default gateway"
  default     = ""
}

variable "deliverables_path" {
  type        = string
  description = "Path to deliverables directory"
  default     = "./deliverables"
}

variable "dns_servers" {
  type        = list(any)
  description = "List of DNS server IPv4 addresses"
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "rancher_create_user_cluster" {
  type    = bool
  default = false
}

variable "rancher_user_cluster_name" {
  type    = string
  default = ""
}

variable "rancher_user_cluster_cpu" {
  type    = string
  default = 2
}

variable "rancher_user_cluster_memoryMB" {
  type    = string
  default = 6144
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
  default = true
}

variable "rancher_node_template_name" {
  type    = string
  default = "vsphere-default"
}

variable "use_auto_dns_url" {
  type    = bool
  default = false
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

# https://github.com/rancher/terraform-provider-rke/releases
variable "kubernetes_version" {
  type    = string
  default = null
}

# https://github.com/rancher/rancher/releases
variable "rancher_version" {
  type    = string
  default = ""
}
