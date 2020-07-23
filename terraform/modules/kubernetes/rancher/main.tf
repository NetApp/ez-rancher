locals {
  deliverables_path  = var.deliverables_path == "" ? "./deliverables" : var.deliverables_path
  alias_initial_node = var.rancher_server_url == join("", [var.cluster_nodes[0].ip, ".nip.io"]) ? 1 : 0
}

resource "rke_cluster" "cluster" {
  depends_on = [var.vm_depends_on]
  # 2 minute timeout specifically for rke-network-plugin-deploy-job but will apply to any addons
  addon_job_timeout = 120
  dynamic "nodes" {
    for_each = [for node in [var.cluster_nodes[0]] : {
      name = node["name"]
      ip   = node["ip"]
    }]
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      user              = "ubuntu"
      role              = ["controlplane", "etcd"]
      ssh_key           = var.ssh_private_key
    }
  }

  dynamic "nodes" {
    for_each = [for node in slice(var.cluster_nodes, 1, length(var.cluster_nodes)) : {
      name = node["name"]
      ip   = node["ip"]
    }]
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      user              = "ubuntu"
      role              = ["worker", "etcd"]
      ssh_key           = var.ssh_private_key
    }
  }
}

resource "local_file" "kubeconfig" {
  filename = format("${local.deliverables_path}/kubeconfig")
  content  = rke_cluster.cluster.kube_config_yaml
}

resource "local_file" "rkeconfig" {
  filename = format("${local.deliverables_path}/rkeconfig.yaml")
  content  = rke_cluster.cluster.rke_cluster_yaml
}

resource "local_file" "ssh_private_key" {
  filename        = format("${local.deliverables_path}/id_rsa")
  content         = var.ssh_private_key
  file_permission = "600"
}

resource "local_file" "ssh_public_key" {
  filename        = format("${local.deliverables_path}/id_rsa.pub")
  content         = var.ssh_public_key
  file_permission = "644"
}

provider "helm" {
  version = "1.2.2"
  kubernetes {
    config_path = format("${local.deliverables_path}/kubeconfig")
  }
}

resource "helm_release" "cert-manager" {
  depends_on       = [local_file.kubeconfig]
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  namespace        = "cert-manager"
  create_namespace = "true"
  wait             = "true"

  set {
    name  = "namespace"
    value = "cert-manager"
  }

  set {
    name  = "version"
    value = "v0.15.0"
  }

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert-manager]

  create_duration = "30s"
}

resource "helm_release" "rancher" {
  depends_on       = [helm_release.cert-manager, time_sleep.wait_for_cert_manager]
  name             = "rancher"
  chart            = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  namespace        = "cattle-system"
  create_namespace = "true"

  set {
    name  = "namespace"
    value = "cattle-system"
  }

  set {
    name  = "hostname"
    value = var.rancher_server_url
  }

  set {
    name  = "ingress.extraAnnotations.nginx\\.ingress\\.kubernetes\\.io/server-alias"
    value = join(" ", formatlist("%s.nip.io", [for node in slice(var.cluster_nodes, local.alias_initial_node, length(var.cluster_nodes)) : node["ip"]]))
  }

}
