# docker build -t ez-rancher:latest .
# docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables ez-rancher:latest apply -state=deliverables/terraform.tfstate

FROM alpine:3.12.0 as binaries

ARG EZR_COMPRESS_BINARIES=false

COPY hack/install_upx.sh hack/compress_binaries.sh /

ENV KUBECTL_VERSION=v1.18.3
ENV TERRAFORM_VERSION=0.14.0
ENV TERRAGRUNT_VERSION=v0.26.6

RUN apk add --no-cache --virtual .build-deps curl \
  && curl -Lo /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x /bin/kubectl \
  && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /bin/terraform \
  && curl -Lo /bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
  && chmod +x /bin/terragrunt \
  && apk del --no-cache .build-deps

COPY terraform/ /terraform/

WORKDIR /terraform/vsphere-rancher

RUN mkdir -p /terraform/vsphere-rancher/.terraform/plugins/ && touch /terraform/vsphere-rancher/.terraform/plugins/.keep \
  && if ${EZR_COMPRESS_BINARIES}; then /install_upx.sh; terraform init; /compress_binaries.sh; terraform init; fi


FROM alpine:3.12.0 as final

ARG GIT_COMMIT=unspecified
LABEL git_commit=$GIT_COMMIT

COPY --from=binaries /bin/terragrunt /bin/kubectl /bin/terraform /bin/

COPY --from=binaries /terraform/ /terraform/

WORKDIR /terraform/vsphere-rancher

RUN terraform init && rm -rf /tmp/*

ENTRYPOINT ["terragrunt"]
