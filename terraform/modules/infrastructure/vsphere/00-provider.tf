provider "vsphere" {
  user                 = var.vsphere-user
  password             = var.vsphere-password
  vsphere_server       = var.vsphere-vcenter
  allow_unverified_ssl = var.vsphere-unverified-ssl
}