variable "control_plane_ips" {
  type = list(string)
}

variable "control_plane_names" {
  type = list(string)
}

variable "worker_ips" {
  type = list(string)
}

variable "worker_names" {
  type = list(string)
}

variable "rancher-server-url" {
  type        = string
  description = "Rancher server-url"
  default     = "my.rancher.org"
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

variable "vm_depends_on" {
  type    = any
  default = null
}