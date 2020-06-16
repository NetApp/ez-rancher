help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build:  ## Build container image
	docker build -t terraform-rancher:latest .

.PHONY: shell
shell:  ## Drop into a docker shell with terraform
	docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables --entrypoint /bin/sh terraform-rancher:latest
	true

.PHONY: validate
validate:  ## Validate terraform
	terraform validate terraform/vsphere-rancher

.PHONY: fmt
fmt:  ## Fixes formatting
	terraform fmt -write=true -recursive -diff .
