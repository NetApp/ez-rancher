IMAGE_TAG ?= latest
IMAGE_NAME ?= netapp/ez-rancher
REGISTRY ?= index.docker.io/netapp# Default to DockerHub but can substitute gcr, quay or registry:5000
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build 
build:  ## Build container image (set $IMAGE_TAG or use default of `dev`)
	IMAGE_TAG=${IMAGE_TAG} hack/rancher-build.sh

.PHONY: push-latest-image
push-latest-image: export IMAGE_TAG := latest ## Push a container image with the latest tag
push-latest-image: build push

.PHONY: push
push: ## Push a Container image (ez-rancher:$IMAGE_TAG) to the specified registry ($REGISTRY, defaults to DockerHub	 )
	docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
	docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}

.PHONY: shell
shell:  ## Drop into a docker shell with terraform (used for debug and development purposes, shell access may be removed from the container in the future)
	docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars \
	       -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables --entrypoint /bin/sh \
		   ${IMAGE_NAME}:${IMAGE_TAG}
	true

.PHONY: validate
validate:  ## Validate terraform
	terraform validate terraform/vsphere-rancher

.PHONY: fmt
fmt:  ## Fixes formatting
	terraform fmt -write=true -recursive -diff .

.PHONY: rancher-up
rancher-up: ## Runs the ez-rancher container deploying rancher server on vSphere
	IMAGE_NAME=${IMAGE_NAME} IMAGE_TAG=${IMAGE_TAG} hack/runner.sh apply

.PHONY: rancher-destroy
rancher-destroy: ## Runs the ez-rancher container, destroying a rancher server previously deployed with rancher-up
	IMAGE_NAME=${IMAGE_NAME} IMAGE_TAG=${IMAGE_TAG}  hack/runner.sh destroy
