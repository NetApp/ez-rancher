#!/usr/bin/env bash

IMAGE_TAG=${IMAGE_TAG:-dev}
if ( ! docker stats --no-stream > /dev/null ); then
  echo 'Docker daemon is not running. Exiting'
  exit 1;
fi

operation=$1
tfvars=${2:-"${PWD}/rancher.tfvars"}
deliverables=${3:-"${PWD}/deliverables"}
if [ ! -f "$tfvars" ]; then
  echo 'Local tfvars file not found at:'
  echo "$tfvars"
  echo 'Exiting'
  exit 1;
fi

if [ ! -d "$deliverables" ]; then
  echo 'Local deliverables file not found at:'
  echo "$deliverables"
  echo 'Attempting to create it for you...'
  mkdir -p "$deliverables"
fi

make image
docker run -it --rm -v "$tfvars":/terraform/vsphere-rancher/rancher.tfvars -v "$deliverables":/terraform/vsphere-rancher/deliverables terraform-rancher:"$IMAGE_TAG" "$operation" -auto-approve -var-file=/terraform/vsphere-rancher/rancher.tfvars -state=deliverables/terraform.tfstate
