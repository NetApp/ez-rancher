resource "time_sleep" "wait_30_seconds" {
  depends_on      = [helm_release.rancher]
  create_duration = "30s"
}

provider "rancher2" {
  alias = "bootstrap"

  api_url   = join("", ["https://", var.rancher_server_url])
  bootstrap = true
  insecure  = true
}

resource "rancher2_bootstrap" "admin" {
  provider   = rancher2.bootstrap
  depends_on = [time_sleep.wait_30_seconds]

  password  = var.rancher_password
  telemetry = true
}

provider "rancher2" {
  alias = "admin"

  api_url   = rancher2_bootstrap.admin.url
  token_key = rancher2_bootstrap.admin.token
  insecure  = true
}

data "dns_a_record_set" "vcenter" {
  host = var.rancher_vsphere_server
}

resource "rancher2_cloud_credential" "vsphere" {
  count = var.create_default_credential ? 1 : 0

  provider    = rancher2.admin
  name        = "vsphere"
  description = "vsphere"
  vsphere_credential_config {
    username     = var.rancher_vsphere_username
    password     = var.rancher_vsphere_password
    vcenter      = data.dns_a_record_set.vcenter.addrs[0]
    vcenter_port = var.rancher_vsphere_port
  }
}

resource "rancher2_node_template" "vsphere" {
  count = var.create_default_credential ? 1 : 0

  name     = "default-vsphere"
  provider = rancher2.admin

  description         = "vsphere"
  cloud_credential_id = rancher2_cloud_credential.vsphere[0].id
  vsphere_config {
    cpu_count   = 2
    memory_size = 4096
    datacenter  = var.rancher_vsphere_datacenter
    datastore   = var.rancher_vsphere_datastore
    folder      = var.rancher_vsphere_folder
    network     = [var.rancher_vsphere_network]
    pool        = var.rancher_vsphere_pool
  }
}

resource "rancher2_cluster" "cluster" {
  count    = var.create_user_cluster ? 1 : 0
  name     = var.user_cluster_name
  provider = rancher2.admin

  description = "Default user cluster"
  rke_config {
    network {
      plugin = "canal"
    }
  }
}

resource "rancher2_node_pool" "control_plane" {
  count = var.create_user_cluster ? 1 : 0

  cluster_id       = rancher2_cluster.cluster[0].id
  provider         = rancher2.admin
  name             = join("", [var.user_cluster_name, "-control-plane"])
  hostname_prefix  = join("", [var.user_cluster_name, "-cp-0"])
  node_template_id = rancher2_node_template.vsphere[0].id
  quantity         = 1
  control_plane    = true
  etcd             = true
  worker           = false
}

resource "rancher2_node_pool" "worker" {
  count = var.create_user_cluster ? 1 : 0

  cluster_id       = rancher2_cluster.cluster[0].id
  provider         = rancher2.admin
  name             = join("", [var.user_cluster_name, "-workers"])
  hostname_prefix  = join("", [var.user_cluster_name, "-wrk-0"])
  node_template_id = rancher2_node_template.vsphere[0].id
  quantity         = 2
  control_plane    = false
  etcd             = false
  worker           = true
}