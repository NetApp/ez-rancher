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

variable "deliverables_path" {
  type        = string
  description = "Path to deliverables directory"
  default     = "./deliverables"
}

variable "control_plane_nodes" {
  type    = list
  default = []
}

variable "worker_nodes" {
  type    = list
  default = []
}
