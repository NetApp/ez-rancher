# server - steps on an mnode - build time integration

```bash
kind create cluster --config kind-config.yaml
kind load docker-image terraform-rancher
```

# client - steps from HCC UI

create pvc to save deliverables to  
`metadata.name` must be unique
```bash
kubectl apply -f pvc.yaml
```

create configmap with tfvars file  
`metadata.name` must be unique
```bash
kubectl create configmap terraform-rancher --from-file=terraform.tfvars=../rancher.tfvars
# or
kubectl apply -f configmap.yaml
```

create rancher cluster  
`metadata.name` and `spec.template.metadata.name` must be unique  
`spec.template.volumes[0].configMap.name` must match the configmap `metadata.name`  
`spec.template.volumes[0].persistentVolumeClaim.claimName` must match the pvc `metadata.name`
```bash
kubernetes apply -f job-apply.yaml
```

retrieving deliverables
```bash

```

remove rancher cluster  
`metadata.name` and `spec.template.metadata.name` must be unique  
`spec.template.volumes[0].configMap.name` must match the configmap `metadata.name`  
`spec.template.volumes[0].persistentVolumeClaim.claimName` must match the pvc `metadata.name`  
```bash
kubernetes apply -f job-apply.yaml
```

# troubleshooting
```bash
# show images in kind
docker exec -it kind-control-plane crictl images
```