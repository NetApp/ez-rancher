IMAGE_TAG ?= dev
REGISTRY ?= index.docker.io/netapp # Can substitute gcr, quay or registry:5000
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build 
build:  ## Build container image (set $IMAGE_TAG or use default of `dev`)
	hack/rancher-build.sh

.PHONY: push
push: ## Push a Container image (terraform-rancher:$IMAGE_TAG) to the specified registry ($REGISTRY, defaults to `index.docker.io` )
	docker tag terraform-rancher:${IMAGE_TAG} ${REGISTRY}/terraform-rancher:${IMAGE_TAG}
	docker push ${REGISTRY}/terraform-rancher:${IMAGE_TAG}

.PHONY: shell
shell:  ## Drop into a docker shell with terraform (used for debug and development purposes, shell access may be removed from the container in the future)
	docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables --entrypoint /bin/sh terraform-rancher:${IMAGE_TAG}
	true

.PHONY: validate
validate:  ## Validate terraform
	terraform validate terraform/vsphere-rancher

.PHONY: fmt
fmt:  ## Fixes formatting
	terraform fmt -write=true -recursive -diff .

.PHONY: rancher-up
rancher-up: ## Runs the ez-rancher container deploying rancher server on vSphere
	hack/runner.sh apply

.PHONY: rancher-destroy
rancher-destroy: ## Runs the ez-rancher container, destroying a rancher server previously deployed with rancher-up
	hack/runner.sh destroy
