# Terraform Rancher

----

Terraform Rancher is Infrastructure as Code to deploy Rancher server on vSphere. It creates the VM infrastructure and configures [Rancher server](https://rancher.com/docs/rancher/v2.x/en/overview/).

Terraform Rancher can either be ran directly using the terraform CLI with the required dependencies or simply running the provided docker container.

----

## Requirements

There are 2 ways to run Terraform Rancher:

1. Terraform CLI

    You have a working Terraform environment with the following dependencies:
    * [Terraform](https://www.terraform.io/downloads.html) >= 0.12
    * [Kubectl](https://downloadkubernetes.com/)
    * [Terraform RKE plugin](https://github.com/rancher/terraform-provider-rke)
    * netcat

2. Docker container

    You have a working Docker environment:
    * [Docker](https://docs.docker.com/engine)

### vSphere

#### VM template

The `vm_template_name` must be a cloud-init OVA that is in your vCenter instance. We have tested this Ubuntu image: <https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.ova>

### Network

Network connectivity from where terraform is executed to the `vm_network`. The `vm_network` must also have internet access.

#### DNS

The `rancher_server_url` input must resolve to one of the worker node IPs.

If DHCP is used (default), this can be done after the deployment completes and the worker nodes receive an IP from the `vm_network`.

**Supplemental DNS names**

The Rancher service is also accessible via **\<node ip address>.nip.io** for each node in the cluster. This provides additional hostnames that can be used to access the rancher service in the event of a node failure, or simply for convenience.

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

* IMAGE_TAG (default is `dev`)
* ER_VARS_FILE (default is `./rancher.tfvars`) 
* ER_DELIVERABLES_DIR (default is `./deliverables`, will attempt creation if it doesn't exist)

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
change this tag by setting the `IMAGE_TAG` environment variable to your
desired tag (eg `latest` which we build and publish for each commit).

When building container images, keep in mind that the `make build` option includes
a helper script to gather the current git commit sha and sets a `git_commit` label 
on the image. This provides a mechanism to determine the current git state of tagged
builds that are in use. You can access the label using docker inspect:

```
$ docker inspect ez-rancher:dev  | jq '.[].ContainerConfig.Labels'
{
  "git_commit": "1c35dae6ef81c0bd14439c100a4260f3bff4ccce"
}
```

## Pushing images to a container registry

After building your image, you can also easily push it to your container
registry using the Makefile.  By default, we set a container registry
environment variable ($REGISTRY) to `index.docker.io/netapp`.  You can
set this environment variable to your own DockerHub account as well as
quay, or gcr and push dev builds to your own registry if you like by running
`make push`.

The `push` directive honors both the `IMAGE_TAG` env variable and the `REGISTRY`
env variable.
