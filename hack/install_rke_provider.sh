#!/usr/bin/env sh

RKE_PROVIDER_VERSION=1.0.0

curl -LO https://github.com/rancher/terraform-provider-rke/releases/download/${RKE_PROVIDER_VERSION}/terraform-provider-rke-linux-amd64.tar.gz
tar -xzf terraform-provider-rke-linux-amd64.tar.gz
mkdir -p /root/.terraform.d/plugins/linux_amd64
mv terraform-provider-rke-*/terraform-provider-rke /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke