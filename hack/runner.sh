#!/usr/bin/env bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright 2020 NetApp
#
OPERATION=$1
IMAGE_NAME=${IMAGE_NAME:-netapp/ez-rancher}
IMAGE_TAG=${IMAGE_TAG:-latest}
TFVARS=${ER_VARS_FILE:-"${PWD}/rancher.tfvars"}
DELIVERABLES=${ER_DELIVERABLES_DIR:-"${PWD}/deliverables"}

if [ ! -z ${ER_DEBUG} ] ; then
  set -x
fi

if ( ! docker stats --no-stream > /dev/null ); then
  echo 'Docker daemon is not running. Exiting'
  exit 1;
fi

if [ ! -f "$TFVARS" ]; then
  echo 'Local variables file not found at:'
  echo "$TFVARS"
  echo 'Exiting'
  exit 1;
fi

if [ ! -d "$DELIVERABLES" ]; then
  echo 'Local deliverables file not found at:'
  echo "$DELIVERABLES"
  echo 'Attempting to create it for you...'
  mkdir -p "$DELIVERABLES"
fi

if [ "$OPERATION" == "destroy" ]; then
  # Remove Rancher resources from project state prior to running destroy. 
  # This will allow any additional clusters that the user has created to be retained.
  docker run -it --rm -v "$TFVARS":/terraform/vsphere-rancher/rancher.tfvars -v "$DELIVERABLES":/terraform/vsphere-rancher/deliverables ez-rancher:"$IMAGE_TAG" state rm module.rancher
  docker run -it --rm -v "$TFVARS":/terraform/vsphere-rancher/rancher.tfvars -v "$DELIVERABLES":/terraform/vsphere-rancher/deliverables ez-rancher:"$IMAGE_TAG" "$OPERATION" -auto-approve -var-file=/terraform/vsphere-rancher/rancher.tfvars -target=module.cluster_nodes.vsphere_virtual_machine.node
  echo "removing contents of deliverables directory..."
  rm -rf "$DELIVERABLES"
else
  docker run -it --rm -v "$TFVARS":/terraform/vsphere-rancher/rancher.tfvars -v "$DELIVERABLES":/terraform/vsphere-rancher/deliverables ez-rancher:"$IMAGE_TAG" "$OPERATION" -auto-approve -var-file=/terraform/vsphere-rancher/rancher.tfvars
fi
 
