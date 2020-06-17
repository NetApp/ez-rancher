
resource "vsphere_virtual_machine" "node" {
  count            = var.node_count
  name             = format("${var.vm-name}-${var.type}%02d", count.index + 1)
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vsphere-vm-folder
  num_cpus         = var.vm-cpu
  memory           = var.vm-ram
  guest_id         = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
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
      hostname  = format("${var.vm-name}-${var.type}%02d", count.index + 1)
      user-data = base64encode(data.template_file.userdata.rendered)
    }
  }
  extra_config = {
    "guestinfo.metadata"          = base64encode(file("${path.module}/cloudinit/metadata.yaml"))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(file("${path.module}/cloudinit/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }
  provisioner "local-exec" {
    command = "count=0; until curl -sm 3 http://${self.default_ip_address}:1234; do sleep 1; if [ $count -eq 600 ]; then break; fi; ((count++)); done"
  }
}
