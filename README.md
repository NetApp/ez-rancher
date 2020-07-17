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
The `vm_template_name` must be a cloud-init OVA that is in your vCenter instance. We have tested this Ubuntu image: https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.ova

### Network
Network connectivity from where terraform is executed to the `vm_network`. The `vm_network` must also have internet access.

#### DNS
The `rancher_server_url` input must resolve to one of the worker node IPs. 

If DHCP is used (default), this can be done after the deployment completes and the worker nodes recieve an IP from the `vm_network`. 

**Supplemental DNS names**

The Rancher service is also accessible via **\<node ip address>.nip.io** for each node in the cluster. This provides additional hostnames that can be used to access the rancher service in the event of a node failure, or simply for convenience.

**DNS and Automatic Bootstrapping**

If `bootstrap_rancher` is enabled, there are special considerations with respect to DNS:
* If using `static_ip_addresses`, the `rancher_server_url` must resolve to one or more of the cluster nodes.
* If using DHCP, the `rancher_server_url` will be automatically overridden to **\<ip address of first node>.nip.io**. This is done in order to provide a hostname to access the rancher service for bootstrapping.

## Getting Started
For tfvars config file examples, refer to [tfvars examples](rancher.tfvars.example)

`terraform apply` will create a `deliverables/` directory to save things like the kubeconfig, tfstate, etc

#### Terraform CLI
```bash
# create cluster
terraform apply -var-file=rancher.tfvars terraform/vsphere-rancher
# remove cluster
terraform destroy -var-file=rancher.tfvars terraform/vsphere-rancher
```

#### Docker
*Note*: If providing the `ssh_public_key` variable, it will need to be available inside the container. [runner.sh](hack/runner.sh) will bind the key to /terraform/vsphere-rancher/id_rsa.pub

```bash
make image

# create cluster using default arguments
make dockerized-terraform-apply
# create cluster using custom arguments
sh hack/runner.sh apply <path_to_tfvars_file> <path_to_deliverables_directory> <path_to_ssh_key>

# remove cluster using default arguments
make dockerized-terraform-destroy
# remove cluster using custom arguments
sh hack/runner.sh destroy <path_to_tfvars_file> <path_to_deliverables_directory>

```

or

```bash
make shell
# create cluster
terraform apply -var-file=terraform.tfvars -state=deliverables/terraform.tfstate
# remove cluster
terraform destroy -var-file=terraform.tfvars -state=deliverables/terraform.tfstate
```

## Releases

* [Releases will be published as container images in Github](https://github.com/NetApp/ez-rancher/packages)
```bash
docker login docker.pkg.github.com -u <GITHUB_USER> -p <GITHUB_ACCESS_TOKEN> 
docker pull docker.pkg.github.com/netapp/ez-rancher/terraform-rancher:latest
```

## Creating container images
You can use the `make image` command to easily build a terraform-rancher
container image with all the necessary dependencies.  This will be built
based on the current status of your src directory.

By default we set an Image Tag of "dev" eg terraform-rancher:dev.  You can
change this tag by setting the `IMAGE_TAG` environment variable to your
desired tag (eg `latest` which we build and publish for each commit).

## Pushing images to a container registry
After building your image, you can also easily push it to your container
registry using the Makefile.  By default, we set a container registry
environment variable ($REGISTRY) to `index.docker.io/netapp`.  You can
set this environment varialbe to your own dockerhub account as well as
quay, or gcr and push dev builds to your own registry if you like by running
`make push`.

The `push` directive honors both the `IMAGE_TAG` env variable and the `REGISTRY`
env variable.
