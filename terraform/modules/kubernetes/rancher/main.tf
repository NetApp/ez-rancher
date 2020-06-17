resource "time_sleep" "wait_for_cloudinit" {
  # 2m is probably excessive, but leave it for now
  create_duration = "3m"
}
# We'd like to just use this as our wait for RKE deploy, but then we run into things like ssh keep-alive timeout
# TODO: Look into modifying sshd config to use this instead of a dumb wait like we have above
resource "null_resource" "wait_for_worker_node" {
  depends_on = [time_sleep.wait_for_cloudinit]
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
    connection {
      host        = element(var.worker_ips, length(var.worker_ips))
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh-private-key)
    }
  }
}

resource "null_resource" "wait_for_control_node" {
  depends_on = [null_resource.wait_for_worker_node]
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]
    connection {
      host        = element(var.control_plane_ips, length(var.control_plane_ips))
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh-private-key)
    }
  }
}

resource "rke_cluster" "cluster" {
  depends_on = [null_resource.wait_for_control_node]
  dynamic "nodes" {
    for_each = [for ip in var.control_plane_ips : {
      ip = ip
    }]
    content {
      address = nodes.value.ip
      user    = "ubuntu"
      role    = ["controlplane", "etcd"]
      ssh_key = file(var.ssh-private-key)
    }
  }

  dynamic "nodes" {
    for_each = [for ip in var.worker_ips : {
      ip = ip
    }]
    content {
      address = nodes.value.ip
      user    = "ubuntu"
      role    = ["worker"]
      ssh_key = file(var.ssh-private-key)
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
  content         = file(var.ssh-private-key)
  file_permission = "400"
}

resource "local_file" "ssh_public_key" {
  filename        = "${path.root}/deliverables/id_rsa.pub"
  content         = file(var.ssh-public-key)
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
    value = var.rancher-server-url
  }

  set {
    name  = "extraEnv[0].name"
    value = "CATTLE_SERVER_URL"
  }

  set {
    name  = "extraEnv[0].value"
    value = var.rancher-server-url
  }
}
