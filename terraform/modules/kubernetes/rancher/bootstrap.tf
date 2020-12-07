resource "null_resource" "wait_for_rancher" {
  count = var.rancher_create_node_template ? 1 : 0

  depends_on = [helm_release.rancher]
  provisioner "local-exec" {
    command = "count=0; until $(curl -ks --connect-timeout 3 ${join("", ["https://", var.cluster_nodes[0].ip, ".nip.io"])} > /dev/null 2>&1); do sleep 1; if [ $count -eq 100 ]; then break; fi; count=`expr $count + 1`; done"
  }
}

provider "rancher2" {
  alias = "bootstrap"

  api_url   = join("", ["https://", var.cluster_nodes[0].ip, ".nip.io"])
  bootstrap = true
  insecure  = true
  retries   = 30
}

resource "rancher2_bootstrap" "admin" {
  count = var.rancher_create_node_template ? 1 : 0

  provider   = rancher2.bootstrap
  depends_on = [null_resource.wait_for_rancher[0]]

  password  = var.rancher_password
  telemetry = true
}

provider "rancher2" {
  alias = "admin"

  api_url   = var.rancher_create_node_template ? rancher2_bootstrap.admin[0].url : ""
  token_key = var.rancher_create_node_template ? rancher2_bootstrap.admin[0].token : ""
  insecure  = true
}

data "dns_a_record_set" "vcenter" {
  host = var.rancher_vsphere_server
}

resource "rancher2_cloud_credential" "vsphere" {
  count = var.rancher_create_node_template ? 1 : 0

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

resource "rancher2_setting" "server_url" {
  count      = var.rancher_create_node_template ? 1 : 0
  provider   = rancher2.admin
  depends_on = [rancher2_node_template.vsphere]

  name  = "server-url"
  value = join("", ["https://", var.rancher_server_url])
}

resource "rancher2_node_template" "vsphere" {
  count = var.rancher_create_node_template ? 1 : 0

  name     = var.rancher_node_template_name
  provider = rancher2.admin

  description         = "vsphere"
  cloud_credential_id = rancher2_cloud_credential.vsphere[0].id
  vsphere_config {
    creation_type = "template"
    clone_from    = var.rancher_vm_template_name
    cpu_count     = var.user_cluster_cpu
    memory_size   = var.user_cluster_memoryMB
    datacenter    = var.rancher_vsphere_datacenter
    datastore     = var.rancher_vsphere_datastore
    disk_size     = var.rancher_node_template_disk_size
    folder        = var.rancher_vsphere_folder
    network       = [var.rancher_vsphere_network]
    pool          = var.rancher_vsphere_pool
  }
}

resource "rancher2_cluster" "cluster" {
  count    = var.create_user_cluster && var.rancher_create_node_template ? 1 : 0
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
  count = var.create_user_cluster && var.rancher_create_node_template ? 1 : 0

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
  count = var.create_user_cluster && var.rancher_create_node_template ? 1 : 0

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

resource "local_file" "kubeconfig_user" {
  count = var.create_user_cluster && var.rancher_create_node_template ? 1 : 0

  filename = format("${var.deliverables_path}/kubeconfig_user")
  content  = rancher2_cluster.cluster[0].kube_config
}

resource "local_file" "rancher_api_key" {
  count = var.rancher_create_node_template ? 1 : 0

  filename = format("${var.deliverables_path}/rancher_token")
  content  = rancher2_bootstrap.admin[0].token
}

resource "rancher2_catalog" "trident" {
  count    = var.rancher_create_node_template && var.rancher_create_trident_catalog ? 1 : 0
  provider = rancher2.admin

  name    = "netapp-trident"
  url     = "https://github.com/NetApp/ez-rancher-trident-installer.git"
  version = "helm_v3"
  branch  = var.rancher_trident_installer_branch
}
