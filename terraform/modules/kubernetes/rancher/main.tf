resource "rke_cluster" "cluster" {
  depends_on = [var.vm_depends_on]
  # 2 minute timeout specifically for rke-network-plugin-deploy-job but will apply to any addons
  addon_job_timeout = 120
  dynamic "nodes" {
    for_each = [for node in var.control_plane_nodes : {
      name = node["name"]
      ip   = node["ip"]
    }]
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      user              = "ubuntu"
      role              = ["controlplane", "etcd"]
      ssh_key           = file(var.ssh_private_key)
    }
  }

  dynamic "nodes" {
    for_each = [for node in var.worker_nodes : {
      name = node["name"]
      ip   = node["ip"]
    }]
    content {
      address           = nodes.value.ip
      hostname_override = nodes.value.name
      user              = "ubuntu"
      role              = ["worker"]
      ssh_key           = file(var.ssh_private_key)
    }
  }
}

resource "local_file" "kubeconfig" {
  filename = "${path.root}/deliverables/kubeconfig"
  content  = rke_cluster.cluster.kube_config_yaml
}

resource "local_file" "rkeconfig" {
  filename = "${path.root}/deliverables/rkeconfig.yaml"
  content  = rke_cluster.cluster.rke_cluster_yaml
}

resource "local_file" "ssh_private_key" {
  filename        = "${path.root}/deliverables/id_rsa"
  content         = file(var.ssh_private_key)
  file_permission = "400"
}

resource "local_file" "ssh_public_key" {
  filename        = "${path.root}/deliverables/id_rsa.pub"
  content         = file(var.ssh_public_key)
  file_permission = "400"
}

provider "helm" {
  version = "1.2.2"
  kubernetes {
    config_path = "${path.root}/deliverables/kubeconfig"
  }
}

resource "helm_release" "cert-manager" {
  depends_on       = [local_file.kubeconfig]
  name             = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  namespace        = "cert-manager"
  create_namespace = "true"

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

resource "helm_release" "rancher" {
  depends_on       = [helm_release.cert-manager]
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
    name  = "extraEnv[0].name"
    value = "CATTLE_SERVER_URL"
  }

  set {
    name  = "extraEnv[0].value"
    value = var.rancher_server_url
  }
}
