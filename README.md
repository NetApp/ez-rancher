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

## Getting Started
For tfvars config file examples, refer to [tfvars examples](docs/TfvarsExamples.md)

`terraform apply` will create a `deliverables/` directory to save things like the kubeconfig, ssh keys, etc

#### Terraform CLI
```bash
# create cluster
terraform apply -var-file=rancher.tfvars terraform/vsphere-rancher
# remove cluster
terraform destroy -var-file=rancher.tfvars terraform/vsphere-rancher
```

#### Docker
```bash
make image
# create cluster
docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables terraform-rancher apply -state=deliverables/terraform.tfstate
# remove cluster
docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables terraform-rancher destroy -state=deliverables/terraform.tfstate
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