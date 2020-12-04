# EZ Rancher

----

EZ Rancher is Infrastructure as Code to deploy Rancher server on vSphere. It creates the VM infrastructure and configures [Rancher server](https://rancher.com/docs/rancher/v2.x/en/overview/) and will optionally create a Rancher user cluster.

----

## Requirements

There are 2 ways to run EZ-Rancher:

1. Docker container (Recommended)

    You have a working Docker environment:
    * [Docker](https://docs.docker.com/engine)

2. Terraform CLI

    You have a working Terraform environment with the following dependencies:
    * [Terraform](https://www.terraform.io/downloads.html) >= 0.14
    * [Kubectl](https://downloadkubernetes.com/)
    * [Terraform RKE plugin](https://github.com/rancher/terraform-provider-rke)
    * netcat

> We recommend you check the CVE for the above tools and only use versions without security issues and 
> have at least 2 GB of memory free in the environment running ez-rancher.

### vSphere

The following tfvars parameters specify how Rancher will be deployed within your vSphere environment.

#### VM template

The `vm_template_name` must be a cloud-init OVA that is in your vCenter instance. We have tested this Ubuntu image: <https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.ova>

#### Data Center

The `vm_datacenter` should be set to the vSphere DataCenter that has access to the remaining vSphere parameters.

#### Resource Pool

The `vsphere_resource_pool` can be the name of a vSphere ResourcePool or Cluster.  If using a Cluster, then be sure to add "/Resources" after the name of the Cluster, like `gpu_cluster/Resources`.  The default value for this parameter is `Resources` which works fine for data centers that have a single cluster.

#### DataStore

The `vm_datastore` is the vSphere DataStore that will provide storage for the VMs that will compose Rancher Server. It must be set to a VMFS DataStore to support disk resizing.

### Network

Network connectivity from where terraform is executed to the `vm_network`. The `vm_network` must also have internet access.

#### DNS

The `rancher_server_url` input must resolve to one or more of the worker node IPs.

If DHCP is used (default), this can be done after the deployment completes and the worker nodes receive an IP from the `vm_network`.

#### Auto DNS URL

If the `use_auto_dns_url` parameter is set to `true`, then the `rancher_server_url` will be automatically set to the following URL:

```bash
https://<IP of primary node>.nip.io
```

This URL allow you to start using Rancher right away, eliminating the need to configure DNS manually.

#### Proxy

If using an HTTP/HTTPS proxy server to access the internet, please set both the `http_proxy` and `https_proxy` variables.

The HTTP/HTTPS proxy will be set on the VM OS and docker runtime. The HTTP proxy and no proxy settings will be configured on Rancher server.
Make sure you add the Service cluster IP range (default: 10.43.0.1⁄16) and any worker cluster controlplane nodes to the `no_proxy` variable.

## Getting Started

For tfvars config file examples, refer to [tfvars examples](rancher.tfvars.example)

`terraform apply` will create a `deliverables/` directory to save things like the kubeconfig, ssh keys, etc...  

### Docker (Recommended)

We rely on environment variables for setting image tags, pointing to rancher variables files and providing
a directory to put deployment output/deliverables in:

* EZR_IMAGE_TAG (default is `latest`)
* EZR_VARS_FILE (default is `./rancher.tfvars`)
* EZR_DELIVERABLES_DIR (default is `./deliverables`, will attempt creation if it doesn't exist)

```bash
# create cluster using default arguments
make rancher-up

# remove cluster using default arguments
make rancher-destroy
```

> The `make rancher-destroy` directive will not only tear down a cluster deployed with `make rancher-up` but it will
also clean up/remove the deliverables files generated from that run.  As such, if for some reason you'd like to save
files from a previous run you'll want to copy them to another location.

```bash
# direct docker command to create the cluster
docker run -it --rm ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables netapp/ez-rancher apply -auto-approve
```

```bash
# direct docker command to delete a created cluster
docker run -it --rm ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables netapp/ez-rancher destroy -auto-approve
```

### Terraform CLI

```bash
terraform init terraform/vsphere-rancher
# create cluster
terraform apply -var-file=rancher.tfvars terraform/vsphere-rancher
# remove cluster
terraform destroy -var-file=rancher.tfvars terraform/vsphere-rancher
```

### Runner Script

Download the `runner.zip` package from our [Releases](https://github.com/NetApp/ez-rancher/releases) page to run the installation from a shell script;  Docker remains a prerequisite.

* Select the release (the most recent is recommended) and `wget https://github.com/NetApp/ez-rancher/releases/_release_/runner.zip`
* Unzip the artifact.
* Copy `rancher.tfvars.example` to `rancher.tfvars`
* Tune `rancher.tfvars` for your environment.
* Run `./runner.sh apply` to install Rancher Server
* Optionally run `./runner.sh destroy` to remove Rancher Server.  _All downstream clusters will not be disturbed by this action._

### Deliverables

Every method to run ez-rancher will create several files based on the `deliverables_path` variable to save things like the kubeconfig, ssh keys, etc

* See [Admin Access to Cluster Nodes](#admin-access-to-cluster-nodes) for more details.

#### Node Access

ez-rancher will generate an SSH key pair for RKE node communication. The generated key pair will be saved to the `deliverables_path` directory.

Additionally, the `ssh_public_key` variable can optionally set an authorized_key on each node for admin access.

#### Node Template and User Cluster

ez-rancher can provision a node template and a sample user cluster.  Use the `rancher_create_node_template` variable to create the node template for the vCenter values provided.  The `rancher_node_template_name` parameter can be used to customize the name so it is familiar to your organization.

Then use `rancher_create_user_cluster` to provision a 3 node user cluster that can be immediately used.  The node template is a prerequisite to create a user cluster.  Therefore `rancher_create_node_template` must be enabled to provision a user cluster.
> By creating a node template or user cluster, you are also accepting the [Rancher EULA](https://rancher.com/eula).

## Releases

[Releases](https://github.com/NetApp/ez-rancher/releases) will be published as container images in [Docker Hub](https://hub.docker.com/r/netapp/ez-rancher/tags)

Releases created in GitHub will generate ez-rancher images tagged with the release version in Docker Hub.
Latest will point to the latest tagged release version. Commits to the main branch will not
automatically publish a new image, but the image can be [created locally](#create-image).

```bash
docker pull netapp/ez-rancher:latest
```

### Images Tagged By Name

Releases where the API does not change will be tagged with a name instead of a semver and will get updated periodically
with fixes and enhancements that do not affect the API contract.

| Tag |   Summary |
| :-----: | :-----: |
|   bryce-canyon	  |Initial release |

## Creating Container Images

You can use the `make build` command to easily build an ez-rancher
container image with all the necessary dependencies.  This will be built
based on the current status of your src directory.

By default, we set an Image Tag of "latest" eg ez-rancher:latest.  You can
change this tag by setting the `EZR_IMAGE_TAG` environment variable to your
desired tag.

```bash
export EZR_IMAGE_TAG=dev
make build
EZR_IMAGE_NAME=ez-rancher make rancher-up
```

When building container images, keep in mind that the `make build` option includes
a helper script to gather the current git commit sha and sets a `git_commit` label
on the image. This provides a mechanism to determine the current git state of tagged
builds that are in use. You can access the label using docker inspect:

```bash
$ docker inspect ez-rancher:latest  | jq '.[].ContainerConfig.Labels'
{
  "git_commit": "1c35dae6ef81c0bd14439c100a4260f3bff4ccce"
}
```

A container image over 70% smaller can be created by setting the environment variable `EZR_COMPRESS_BINARIES` to `true`. This will compress `terraform`, `kubectl` and all Terraform plugin binaries.

```bash
export EZR_COMPRESS_BINARIES=true; make build
```

> *Be advised that with `EZR_COMPRESS_BINARIES=true` the image build process is optimized for image size over build duration.*

## Pushing Images to a Container Registry

After building your image, you can also easily push it to your container
registry using the Makefile.  By default, we set a container registry
environment variable ($EZR_REGISTRY) to `index.docker.io/netapp`.  You can
set this environment variable to your own DockerHub account as well as
quay, or gcr and push dev builds to your own registry if you like by running
`make push`.

The `push` directive honors both the `EZR_IMAGE_TAG` env variable and the `EZR_REGISTRY`
env variable.

## Verifying the Installation

After installation, the some information will be displayed about your installation:

```bash
Outputs:

cluster_nodes = [
  {
    "ip" = "10.1.1.2"
    "name" = "my-node01"
  },
  {
    "ip" = "10.1.1.3"
    "name" = "my-node02"
  },
  {
    "ip" = "10.1.1.4"
    "name" = "my-node03"
  },
]
rancher_server_url = https://<Your Rancher URL>
```

## Accessing Rancher UI

In order to access the Rancher UI via your chosen `rancher_server_url`, you must ensure that a valid DNS record exists, that resolves to one or more of your cluster node IPs.

Once the DNS record is in place, the Rancher UI will become accessible at the location specified for `rancher_server_url`.

### Automatic DNS Names

If you have not yet configured DNS, the Rancher UI can also be accessed via the following URL syntax, using the IP address of any node in the cluster:

```bash
https://<IP of node>.nip.io
```

> A valid DNS record must be in place for the `rancher_server_url` before Rancher will become fully functional. To eliminate this DNS requirement, see [Auto DNS URL](#auto-dns-url)*

## Admin Access to Cluster Nodes

If desired, administrative access to the cluster nodes is possible via the following methods:

### Kubectl

Access to the K8S cluster on which Rancher is running can be performed by configuring `kubectl` to use the config file located at `deliverables/kubeconfig`:

```bash
$ export KUBECONFIG=`pwd`/deliverables/kubeconfig
$ kubectl get nodes
NAME             STATUS   ROLES              AGE     VERSION
node01   Ready    controlplane,etcd,worker   5m30s   v1.17.5
node02   Ready    controlplane,etcd,worker   5m30s   v1.17.5
node03   Ready    controlplane,etcd,worker   5m30s   v1.17.5
```

### SSH

SSH access to the nodes is possible via the SSH key generated in the `deliverables/` directory. The username used will depend on which VM template was used to deploy the cluster. For ubuntu-based images, the username is `ubuntu`:

```bash
$ ssh -i ./deliverables/id_rsa ubuntu@<node IP address>
```
