# EZ Rancher

----

EZ Rancher is Infrastructure as Code to deploy Rancher server on vSphere. It creates the VM infrastructure and configures [Rancher server](https://rancher.com/docs/rancher/v2.x/en/overview/).

----

## Requirements

There are 2 ways to run EZ-Rancher:

1. Docker container (Recommended)

    You have a working Docker environment:
    * [Docker](https://docs.docker.com/engine)

2. Terraform CLI

    You have a working Terraform environment with the following dependencies:
    * [Terraform](https://www.terraform.io/downloads.html) >= 0.12
    * [Kubectl](https://downloadkubernetes.com/)
    * [Terraform RKE plugin](https://github.com/rancher/terraform-provider-rke)
    * netcat

### vSphere

#### VM template

The `vm_template_name` must be a cloud-init OVA that is in your vCenter instance. We have tested this Ubuntu image: <https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.ova>

### Network

Network connectivity from where terraform is executed to the `vm_network`. The `vm_network` must also have internet access.

#### DNS

The `rancher_server_url` input must resolve to one of the worker node IPs.

If DHCP is used (default), this can be done after the deployment completes and the worker nodes receive an IP from the `vm_network`.

#### Supplemental DNS names

See [Automatic DNS names](#automatic-dns-names)

## Getting Started

For tfvars config file examples, refer to [tfvars examples](rancher.tfvars.example)

`terraform apply` will create a `deliverables/` directory to save things like the kubeconfig, ssh keys, etc

### Terraform CLI

```bash
# create cluster
terraform apply -var-file=rancher.tfvars terraform/vsphere-rancher
# remove cluster
terraform destroy -var-file=rancher.tfvars terraform/vsphere-rancher
```

### Docker

We rely on environment variables for setting image tags, pointing to rancher variables files and providing
a directory to put deployment output/deliverables in:

* EZR_IMAGE_TAG (default is `dev`)
* EZR_VARS_FILE (default is `./rancher.tfvars`) 
* EZR_DELIVERABLES_DIR (default is `./deliverables`, will attempt creation if it doesn't exist)

```bash
make build

# create cluster using default arguments
make rancher-up

# remove cluster using default arguments
make rancher-destroy

```

*NOTE*

The `make rancher-destroy` directive will not only tear down a cluster deployed with `make cluster-up` but it will
also clean up/remove the deliverables files generated from that run.  As such, if for some reason you'd like to save
files from a previous run you'll want to copy them to another location.

### Deliverables

ez-rancher will create several files based on the `deliverables_path` variable to save things like the kubeconfig, ssh keys, etc

* See [Admin Access to Cluster Nodes](#admin-access-to-cluster-nodes) for more details.

#### Node Access

ez-rancher will generate an SSH key pair for RKE node communication. The generated key pair will be saved to the `deliverables_path` directory.

Additionally, the `ssh_public_key` variable can optionally set an authorized_key on each node for admin access.

## Releases

* [Releases will be published as container images in Github](https://github.com/NetApp/ez-rancher/packages)

```bash
docker login docker.pkg.github.com -u <GITHUB_USER> -p <GITHUB_ACCESS_TOKEN>
docker pull docker.pkg.github.com/netapp/ez-rancher/ez-rancher:latest
```

## Creating container images

You can use the `make build` command to easily build a ez-rancher
container image with all the necessary dependencies.  This will be built
based on the current status of your src directory.

By default, we set an Image Tag of "dev" eg ez-rancher:dev.  You can
change this tag by setting the `EZR_IMAGE_TAG` environment variable to your
desired tag (eg `latest` which we build and publish for each commit).

When building container images, keep in mind that the `make build` option includes
a helper script to gather the current git commit sha and sets a `git_commit` label 
on the image. This provides a mechanism to determine the current git state of tagged
builds that are in use. You can access the label using docker inspect:

```bash
$ docker inspect ez-rancher:dev  | jq '.[].ContainerConfig.Labels'
{
  "git_commit": "1c35dae6ef81c0bd14439c100a4260f3bff4ccce"
}
```

A container image over 70% smaller can be created by setting the environment variable `EZR_COMPRESS_BINARIES` to `true`. This will compress `terraform`, `kubectl` and all Terraform plugin binaries.

```bash
export EZR_COMPRESS_BINARIES=true; make build
```

NOTE - *Be advised that with `EZR_COMPRESS_BINARIES=true` the image build process is optimized for image size over build duration.*

## Pushing images to a container registry

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

## Accessing the Rancher UI

In order to access the Rancher UI via your chosen `rancher_server_url`, you must ensure that a valid DNS record exists, that resolves to one or more of your cluster node IPs.

Once the DNS record is in place, the Rancher UI will become accessible at the location specified for `rancher_server_url`.

### Automatic DNS Names

If you have not yet configured DNS (or prefer not to), the Rancher UI can also be accessed via the following URL syntax, using the IP address of any node in the cluster:

```bash
https://<IP of node>.nip.io
```

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
