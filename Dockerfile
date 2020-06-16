# docker build -t terraform-rancher:latest .
# docker run -it --rm -v ${PWD}/rancher.tfvars:/terraform/vsphere-rancher/rancher.tfvars -v ${PWD}/deliverables:/terraform/vsphere-rancher/deliverables terraform-rancher:latest apply -state=deliverables/terraform.tfstate
FROM hashicorp/terraform:light AS builder

ENV KUBECTL_VERSION=v1.17.4
ENV RKE_PROVIDER_VERSION=1.0.0

RUN apk add curl \
  && curl -Lo /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x /bin/kubectl \
  && curl -LO https://github.com/rancher/terraform-provider-rke/releases/download/${RKE_PROVIDER_VERSION}/terraform-provider-rke-linux-amd64.tar.gz \
  && tar -xzf terraform-provider-rke-linux-amd64.tar.gz \
  && mkdir -p /root/.terraform.d/plugins/linux_amd64 \
  && mv terraform-provider-rke-*/terraform-provider-rke /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke \
  && rm -rf terraform-provider-rke-linux-amd64.tar.gz \
  && rm -rf terraform-provider-rke-* \
  && ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa

COPY terraform/ /terraform/

WORKDIR /terraform/vsphere-rancher
RUN terraform init

FROM alpine:3.12.0

WORKDIR /terraform/vsphere-rancher

COPY terraform/ /terraform/

COPY --from=builder /bin/kubectl /bin/kubectl
COPY --from=builder /bin/terraform /bin/terraform
COPY --from=builder /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke /root/.terraform.d/plugins/linux_amd64/terraform-provider-rke
COPY --from=builder /root/.ssh/id_rsa /root/.ssh/id_rsa
COPY --from=builder /root/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub
COPY --from=builder /terraform/vsphere-rancher/.terraform/plugins/linux_amd64/* /terraform/vsphere-rancher/.terraform/plugins/linux_amd64/

RUN terraform init
ENTRYPOINT ["terraform"]
