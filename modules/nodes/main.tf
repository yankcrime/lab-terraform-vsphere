resource "vsphere_virtual_machine" "vm" {
  count            = var.num
  name             = "${var.name}-${count.index}"
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore_id

  num_cpus = var.cpus
  memory   = var.memory
  guest_id = var.guest_id

  network_interface {
    network_id   = var.network_id
    adapter_type = var.adapter_type
  }

  disk {
    label = "disk0"
    size  = var.disk_size
  }

  clone {
    template_uuid = var.template_uuid
    customize {
      linux_options {
        host_name = "${var.name}-${count.index}"
        domain    = var.domain_name
      }

      network_interface {}
    }
  }
  tags = var.tags

  extra_config = {
    "guestinfo.userdata"          = base64encode(file("${path.module}/templates/userdata.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }

}
