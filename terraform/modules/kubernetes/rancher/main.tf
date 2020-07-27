locals {
  deliverables_path  = var.deliverables_path == "" ? "./deliverables" : var.deliverables_path
  alias_initial_node = var.rancher_server_url == join("", [var.cluster_nodes[0].ip, ".nip.io"]) ? 1 : 0
}

resource "rke_cluster" "cluster" {
  depends_on = [var.vm_depends_on]
  # 2 minute timeout specifically for rke-network-plugin-deploy-job but will apply to any addons
  addon_job_timeout = 120
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
  wait             = "false"

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

provider "kubernetes" {
  config_path = format("${local.deliverables_path}/kubeconfig")
}

resource "tls_private_key" "cert" {
  depends_on = [helm_release.cert-manager]
  algorithm  = "ECDSA"
}

resource "tls_self_signed_cert" "cert" {
  depends_on      = [tls_private_key.cert]
  key_algorithm   = tls_private_key.cert.algorithm
  private_key_pem = tls_private_key.cert.private_key_pem

  is_ca_certificate     = true
  validity_period_hours = 12

  early_renewal_hours = 3

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["example.com", "example.net"]

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }
}

resource "null_resource" "wait_k8s_api" {
  depends_on = [rke_cluster.cluster, local_file.kubeconfig, tls_self_signed_cert.cert]

  provisioner "local-exec" {
    command = "export KUBECONFIG=${format("${local.deliverables_path}/kubeconfig")}; export count=0; until [ $(kubectl get nodes > /dev/null 2>&1) ]; do sleep 1; if [ $count -eq 100 ]; then break; fi; count=`expr $count + 1`; done"
  }
}

resource "null_resource" "create_secret" {
  depends_on = [null_resource.wait_k8s_api]

  provisioner "local-exec" {
    command = "export KUBECONFIG=${format("${local.deliverables_path}/kubeconfig")}; export count=0; until [ $(kubectl create secret generic ca-key-pair --from-literal='tls.crt=${tls_self_signed_cert.cert.cert_pem}' --from-literal='tls.key=${tls_private_key.cert.private_key_pem}' > /dev/null 2>&1) ]; do sleep 1; if [ $count -eq 100 ]; then break; fi; count=`expr $count + 1`; done"
  }
}

data "template_file" "test_cert" {
  template = file("${path.module}/templates/cert.tpl")
}

resource "null_resource" "create_ca" {
  depends_on = [helm_release.cert-manager, null_resource.create_secret]

  provisioner "local-exec" {
    command = "export KUBECONFIG=${format("${local.deliverables_path}/kubeconfig")}; export count=0; until [ $(echo '${data.template_file.test_cert.rendered}' | kubectl apply -f - > /dev/null 2>&1) ]; do sleep 1; if [ $count -eq 100 ]; then break; fi; count=`expr $count + 1`; done"
  }
}

resource "null_resource" "verify_ca" {
  depends_on = [null_resource.create_ca]

  provisioner "local-exec" {
    command = "KUBECONFIG=${format("${local.deliverables_path}/kubeconfig")} kubectl wait issuer ca-issuer --for condition=ready --timeout=1m --namespace default"
  }
}


resource "helm_release" "rancher" {
  depends_on       = [null_resource.verify_ca]
  name             = "rancher"
  chart            = "rancher"
  repository       = "https://releases.rancher.com/server-charts/stable"
  namespace        = "cattle-system"
  create_namespace = "true"
  wait             = "false"

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
