
terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
}

resource "tls_private_key" "key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "vsphere_virtual_machine" "node" {
  count            = var.node_count
  name             = format("${var.vm_name}-${var.type}%02d", count.index + 1)
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere_vm_folder
  num_cpus         = var.vm_cpu
  memory           = var.vm_ram
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  hardware_version = var.vm_hardware_version

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = length(data.vsphere_virtual_machine.template.network_interface_types) == 0 ? "vmxnet3" : data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  # For static IPs, we will write the netplan in cloud-init to configure the network so disable net timeout in that case
  wait_for_guest_net_timeout = local.num_addresses == 0 ? 5 : 0
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size > 20 ? data.vsphere_virtual_machine.template.disks.0.size : 20
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  cdrom {
    client_device = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
  vapp {
    properties = {
      hostname  = format("${var.vm_name}-${var.type}%02d", count.index + 1)
      user-data = base64encode(data.template_file.kickstart_userdata[count.index].rendered)
    }
  }
  extra_config = {
    "guestinfo.metadata"          = base64encode(data.template_file.metadata[count.index].rendered)
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(data.template_file.userdata.rendered)
    "guestinfo.userdata.encoding" = "base64"
  }
  provisioner "local-exec" {
    # Wait for cloud-init userdata cmds
    # Netcat: z (scan port only), w1 (wait 1 second)
    command = "count=0; until $(nc -zw1 ${local.num_addresses == 0 ? self.default_ip_address : local.node_ips_no_mask[count.index]} 1234); do sleep 1; if [ $count -eq 900 ]; then break; fi; count=`expr $count + 1`; done"
  }
}
