resource "time_sleep" "wait_30_seconds" {
  destroy_duration = "30s"
}

provider "rancher2" {
  alias = "bootstrap"
  depends_on = ["time_sleep.wait_30_seconds"]

  api_url   = join("", ["https://", var.rancher_server_url])
  bootstrap = true
  insecure = true
}

resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap

  password = "solidfire"
  telemetry = true
}

provider "rancher2" {
  alias = "admin"

  api_url = rancher2_bootstrap.admin.url
  token_key = rancher2_bootstrap.admin.token
  insecure = true
}

resource "rancher2_cloud_credential" "vsphere" {
  count = var.create_default_credential ? 1 : 0

  provider = rancher2.admin
  name = "vsphere"
  description = "vsphere"
  vsphere_credential_config {
    username = var.rancher_vsphere_username
    password = var.rancher_vsphere_password
    vcenter  = var.rancher_vsphere_server
    vcenter_port = var.rancher_vsphere_port
  }
}

resource "rancher2_node_template" "vsphere" {
  name = "default-vsphere"
  provider = rancher2.admin

  description = "vsphere"
  cloud_credential_id = rancher2_cloud_credential.vsphere[0].id
  vsphere_config {
    datacenter = var.rancher_vsphere_datacenter
    datastore = var.rancher_vsphere_datastore
    folder = var.rancher_vsphere_folder
    network = [var.rancher_vsphere_network]
    pool = var.rancher_vsphere_pool
  }
}