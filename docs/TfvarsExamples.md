# Example rancher.tfvars
There are a few different configuration options that can be set in the rancher.tfvars file for Terraform Rancher. Here are some examples of files:  

## DHCP
```hcl-terraform
vsphere_user           = "administrator@vsphere.local"
vsphere_password       = "secret"
vsphere_unverified_ssl = "true"
vsphere_vcenter        = "vcenter.example.com"
vsphere_datacenter     = "NetApp-HCI-Datacenter-01"
vm_datastore           = "NetApp-HCI-Datastore-01"
vm_network             = "NetApp HCI VDS 01-VM_Network"
vm_name                = "rancher"
vm_template_name       = "bionic-server-cloudimg-amd64"
```

## User defined IP addresses
```hcl-terraform
control_plane_count    = 1
worker_count           = 2
vm_cpu                 = 2
vm_ram                 = 8196
vm_name                = "rancher"
vm_template_name       = "bionic-server-cloudimg-amd64"
vsphere_vcenter        = "vcenter.example.com"
vsphere_user           = "user"
vsphere_password       = "secret"
vsphere_unverified_ssl = "true"
vsphere_datacenter     = "NetApp-HCI-Datacenter-01"
vm_datastore           = "NetApp-HCI-Datastore-01"
vm_network             = "NetApp HCI VDS 01-VM_Network"
rancher_server_url     = "rancher.example.com"
static_ip_addresses    = ["10.1.1.2/24", "10.1.1.3/24", "10.1.1.4/24"]
default_gateway        = "10.1.1.1"
bootstrap_rancher      = false
rancher_password       = "solidfire"
```
