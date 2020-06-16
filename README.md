# Terraform Rancher
Terraform to deploy Rancher server on vSphere

## Requirements
If you're running locally:
* [Terraform](https://www.terraform.io/downloads.html) >= 0.12
* [Kubectl](https://downloadkubernetes.com/)
* [Terraform RKE plugin](https://github.com/rancher/terraform-provider-rke)

## Usage

#### Local
```bash
terraform apply -var-file=rancher.tfvars terraform/vsphere-rancher
```

#### Docker
```bash
make build
docker run -it --rm -v ${PWD}/terraform.tfvars:/terraform/terraform.tfvars -v ${PWD}/deliverables:/terraform/deliverables terraform-rancher apply -state=deliverables/terraform.tfstate
```

or

```bash
make shell
terraform apply -var-file=rancher.tfvars -state=deliverables/terraform.tfstate
```

## Notes

* `terraform apply` will create a `deliverables/` directory to save things like the kubeconfig, ssh keys, etc
* Releases will be published as container images in Github