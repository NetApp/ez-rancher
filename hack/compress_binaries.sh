#!/usr/bin/env sh

# compress binaries
echo -e "======== compressing binaries"
upx /bin/terraform /bin/kubectl /bin/terragrunt
echo -e "========"

# compress terraform plugins
echo -e "======== compressing terraform plugins"
upx /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke /terraform/vsphere-rancher/.terraform/plugins/linux_amd64/*
echo -e "========"
