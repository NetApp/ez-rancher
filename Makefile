EZR_IMAGE_TAG ?= latest
EZR_IMAGE_NAME ?= netapp/ez-rancher
EZR_REGISTRY ?= index.docker.io/netapp# Default to DockerHub but can substitute gcr, quay or registry:5000
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build 
build:  ## Build container image (set $EZR_IMAGE_TAG or use default of `latest`)
	EZR_IMAGE_TAG=${EZR_IMAGE_TAG} hack/rancher-build.sh

.PHONY: push-latest-image
push-latest-image: build push

.PHONY: push
push: ## Push a Container image (ez-rancher:$EZR_IMAGE_TAG) to the specified registry ($EZR_REGISTRY, defaults to DockerHub	 )
	docker tag ${EZR_IMAGE_NAME}:${EZR_IMAGE_TAG} ${EZR_REGISTRY}/${EZR_IMAGE_NAME}:${EZR_IMAGE_TAG}
	docker push ${EZR_REGISTRY}/${EZR_IMAGE_NAME}:${EZR_IMAGE_TAG}

.PHONY: shell
shell:  ## Drop into a docker shell with terraform (used for debug and development purposes, shell access may be removed from the container in the future)
	docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars \
	       -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables --entrypoint /bin/sh \
		   ${EZR_IMAGE_NAME}:${EZR_IMAGE_TAG} || true

.PHONY: validate
validate:  ## Validate terraform
	terraform validate terraform/vsphere-rancher

.PHONY: fmt
fmt:  ## Fixes formatting
	terraform fmt -write=true -recursive -diff .

.PHONY: rancher-up
rancher-up: ## Runs the ez-rancher container deploying rancher server on vSphere
	EZR_IMAGE_NAME=${EZR_IMAGE_NAME} EZR_IMAGE_TAG=${EZR_IMAGE_TAG} hack/runner.sh apply

.PHONY: rancher-destroy
rancher-destroy: ## Runs the ez-rancher container, destroying a rancher server previously deployed with rancher-up
	EZR_IMAGE_NAME=${EZR_IMAGE_NAME} EZR_IMAGE_TAG=${EZR_IMAGE_TAG}  hack/runner.sh destroy
