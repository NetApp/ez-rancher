IMAGE_TAG ?= dev
REGISTRY ?= index.docker.io/netapp # Can substitute gcr, quay or registry:5000
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: image
image:  ## Build container image (set $IMAGE_TAG or use default of `dev`)
	docker build -t terraform-rancher:${IMAGE_TAG} .

.PHONY: push
push: ## Push a Container image (terraform-rancher:$IMAGE_TAG) to the specified registry ($REGISTRY, defaults to `index.docker.io` )
	docker tag terraform-rancher:${IMAGE_TAG} ${REGISTRY}/terraform-rancher:${IMAGE_TAG}
	docker push ${REGISTRY}/terraform-rancher:${IMAGE_TAG}

.PHONY: shell
shell:  ## Drop into a docker shell with terraform
	docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables --entrypoint /bin/sh terraform-rancher:${IMAGE_TAG}
	true

.PHONY: validate
validate:  ## Validate terraform
	terraform validate terraform/vsphere-rancher

.PHONY: fmt
fmt:  ## Fixes formatting
	terraform fmt -write=true -recursive -diff .

.PHONY: dockerized-terraform-apply
dockerized-terraform-apply: ## Executes terraform apply command with default arguments
	hack/runner.sh apply

.PHONY: dockerized-terraform-destroy
dockerized-terraform-destroy: ## Executes terraform destroy command with default arguments
	hack/runner.sh destroy
