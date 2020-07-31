# docker build -t ez-rancher:latest .
# docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/terraform.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables ez-rancher:latest apply -state=deliverables/terraform.tfstate

FROM alpine:3.12.0 as binaries

ARG EZR_COMPRESS_BINARIES=false

COPY hack/install_upx.sh hack/compress_binaries.sh /

ENV KUBECTL_VERSION=v1.18.3
ENV RKE_PROVIDER_VERSION=1.0.1
ENV TERRAFORM_VERSION=0.12.26
ENV TERRAGRUNT_VERSION=v0.23.31-r.1

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
  && curl -Lo /bin/terragrunt https://github.com/sgryczan/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
  && chmod +x /bin/terragrunt \
  && apk del --no-cache .build-deps \
  && rm -rf /tf-provider-rke.zip

COPY terraform/ /terraform/

WORKDIR /terraform/vsphere-rancher

RUN mkdir -p /terraform/vsphere-rancher/.terraform/plugins/linux_amd64/ && touch /terraform/vsphere-rancher/.terraform/plugins/linux_amd64/.keep \
  && if ${EZR_COMPRESS_BINARIES}; then /install_upx.sh; terraform init; /compress_binaries.sh; terraform init; fi


FROM alpine:3.12.0 as final

LABEL git_commit=$GIT_COMMIT

ARG GIT_COMMIT=unspecified

COPY --from=binaries /bin/terragrunt /bin/kubectl /bin/terraform /bin/
COPY --from=binaries /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke
COPY --from=binaries /terraform/vsphere-rancher/.terraform/plugins/linux_amd64/* /terraform/vsphere-rancher/.terraform/plugins/linux_amd64/
COPY terraform/ /terraform/

WORKDIR /terraform/vsphere-rancher

RUN touch terragrunt.hcl && terraform init

ENTRYPOINT ["terragrunt"]
