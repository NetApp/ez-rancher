terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    rke = {
      source = "rancher/rke"
    }
    rancher2 = {
      source = "rancher/rancher2"
    }
  }
}

locals {
  alias_initial_node = var.rancher_server_url == join("", [var.cluster_nodes[0].ip, ".nip.io"]) ? 1 : 0
}

resource "rke_cluster" "cluster" {
  depends_on = [var.vm_depends_on]
  # 2 minute timeout specifically for rke-network-plugin-deploy-job but will apply to any addons
  addon_job_timeout  = 120
  kubernetes_version = var.kubernetes_version
  services {
    kube_api {
      service_cluster_ip_range = var.rancher_service_cidr
    }
    kube_controller {
      cluster_cidr             = var.rancher_cluster_cidr
      service_cluster_ip_range = var.rancher_service_cidr
    }
  }
  dynamic "nodes" {
    for_each = [for node in var.cluster_nodes : {
      name = node["name"]
      ip   = node["ip"]
    }]
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      user              = "ubuntu"
      role              = ["controlplane", "etcd", "worker"]
      ssh_key           = var.ssh_private_key
    }
  }
}

resource "local_file" "kubeconfig" {
  filename = format("${var.deliverables_path}/kubeconfig")
  content  = rke_cluster.cluster.kube_config_yaml
}

resource "local_file" "rkeconfig" {
  filename = format("${var.deliverables_path}/cluster.yml")
  content  = rke_cluster.cluster.rke_cluster_yaml
}

resource "local_file" "rke_state_file" {
  filename = format("${var.deliverables_path}/cluster.rkestate")
  content  = rke_cluster.cluster.rke_state
}

resource "local_file" "ssh_private_key" {
  filename        = format("${var.deliverables_path}/id_rsa")
  content         = var.ssh_private_key
  file_permission = "600"
}

resource "local_file" "ssh_public_key" {
  filename        = format("${var.deliverables_path}/id_rsa.pub")
  content         = var.ssh_public_key
  file_permission = "644"
}

provider "helm" {
  kubernetes {
    config_path = format("${var.deliverables_path}/kubeconfig")
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
  replace          = true

  set {
    name  = "namespace"
    value = "cert-manager"
  }

  set {
    name  = "version"
    value = "v1.1.0"
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
  wait             = "true"
  replace          = true
  version          = var.rancher_version

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

  set {
    name  = "proxy"
    value = var.http_proxy != "" ? var.http_proxy : ""
  }

  set {
    name  = "noProxy"
    value = replace(var.no_proxy, ",", "\\,")
  }

}
