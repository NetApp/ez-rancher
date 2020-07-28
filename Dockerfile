# docker build -t ez-rancher:latest .
# docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/rancher.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables ez-rancher:latest apply -state=deliverables/terraform.tfstate
FROM golang:alpine3.12

ARG EZR_COMPRESS_BINARIES=false
ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT

ENV KUBECTL_VERSION=v1.18.3
ENV RKE_PROVIDER_VERSION=1.0.1
ENV TERRAFORM_VERSION=0.12.26

COPY hack/compress_binaries.sh /compress_binaries.sh
COPY hack/install_upx.sh /install_upx.sh

RUN apk add --no-cache --virtual .build-deps curl \
  && curl -Lo /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x /bin/kubectl \
  && curl -L https://github.com/rancher/terraform-provider-rke/releases/download/v${RKE_PROVIDER_VERSION}/terraform-provider-rke_${RKE_PROVIDER_VERSION}_linux_amd64.zip -o tf-provider-rke.zip \
  && unzip tf-provider-rke.zip \
  && mkdir -p /root/.terraform.d/plugins/linux_amd64 \
  && mv terraform-provider-rke* /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke \
  && rm -rf terraform-provider-rke-linux-amd64.tar.gz \
  && rm -rf terraform-provider-rke-* \
  && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /bin/terraform \
  && apk del --no-cache .build-deps \
  && rm -rf /tf-provider-rke.zip \
  && if ${EZR_COMPRESS_BINARIES}; then /install_upx.sh; /compress_binaries.sh; fi

RUN apk add --no-cache git && \
  git clone https://github.com/sgryczan/terragrunt.git && \
  cd terragrunt && \
  go build -o terragrunt -v && \
  chmod +x terragrunt && \
  mv terragrunt /usr/local/bin && \
  cd .. && rm -rf terragrunt/

COPY terraform/ /terraform/

WORKDIR /terraform/vsphere-rancher
RUN touch terragrunt.hcl
#ARG RELEASE_BUILD=false
RUN terraform init \
  && if ${EZR_COMPRESS_BINARIES}; then /compress_binaries.sh; terraform init; fi \
  && rm -rf /compress_binaries.sh /install_upx.sh /bin/upx

ENTRYPOINT ["terragrunt"]
