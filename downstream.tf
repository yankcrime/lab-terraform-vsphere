resource "vsphere_virtual_machine" "downstream_cluster_control" {
  count        = 1
  name         = "control${count.index}"
  datastore_id = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 2048

  guest_id = data.vsphere_virtual_machine.template.guest_id

  resource_pool_id = data.vsphere_resource_pool.pool.id

  disk {
    label = "disk0"
    size  = 20
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "control${count.index}"
        domain    = "int.dischord.org"
      }
      network_interface {
        ipv4_address = "192.168.1.22${count.index}"
        ipv4_netmask = 24
      }
      ipv4_gateway    = "192.168.1.1"
      dns_server_list = ["192.168.1.1"]
      dns_suffix_list = ["int.dischord.org"]
    }
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  provisioner "file" {
    source      = "${path.module}/templates/provision.sh"
    destination = "/tmp/provision.sh"
    connection {
      host     = self.guest_ip_addresses.0
      type     = "ssh"
      user     = "packerbuilt"
      password = "PackerBuilt!"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/provision.sh",
      "sudo /tmp/provision.sh"
    ]
    connection {
      host     = self.guest_ip_addresses.0
      type     = "ssh"
      user     = "packerbuilt"
      password = "PackerBuilt!"
    }
  }
}

resource "vsphere_virtual_machine" "downstream_cluster_worker" {
  count        = 3
  name         = "worker${count.index}"
  datastore_id = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 2048

  guest_id = data.vsphere_virtual_machine.template.guest_id

  resource_pool_id = data.vsphere_resource_pool.pool.id

  disk {
    label = "disk0"
    size  = 20
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "worker${count.index}"
        domain    = "int.dischord.org"
      }
      network_interface {
        ipv4_address = "192.168.1.23${count.index}"
        ipv4_netmask = 24
      }
      ipv4_gateway    = "192.168.1.1"
      dns_server_list = ["192.168.1.1"]
      dns_suffix_list = ["int.dischord.org"]
    }
  }

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  provisioner "file" {
    source      = "${path.module}/templates/provision.sh"
    destination = "/tmp/provision.sh"
    connection {
      host     = self.guest_ip_addresses.0
      type     = "ssh"
      user     = "packerbuilt"
      password = "PackerBuilt!"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/provision.sh",
      "sudo /tmp/provision.sh"
    ]
    connection {
      host     = self.guest_ip_addresses.0
      type     = "ssh"
      user     = "packerbuilt"
      password = "PackerBuilt!"
    }
  }
}

resource "rancher2_cluster" "downstream_cluster" {
  name                  = "downstream-cluster"
  description           = "Demo downstream cluster"
  enable_network_policy = true

  rke_config {
    kubernetes_version = "v1.18.6-rancher1-2"
    services {
      kube_api {
        secrets_encryption_config {
          enabled = true
        }
      }
    }
  }
}

locals {
  downstream_cluster_nodes = toset([
    vsphere_virtual_machine.downstream_cluster_control.*.default_ip_address,
    vsphere_virtual_machine.downstream_cluster_worker.*.default_ip_address
  ])
}

resource "null_resource" "downstream_cluster_deploy" {
  for_each = {
    "192.168.1.220" : "--controlplane --etcd"
    "192.168.1.230" : "--worker"
    "192.168.1.231" : "--worker"
    "192.168.1.232" : "--worker"
  }

  provisioner "remote-exec" {
    inline = ["${rancher2_cluster.downstream_cluster.cluster_registration_token.0["node_command"]} ${each.value}"]
    connection {
      host     = each.key
      user     = "packerbuilt"
      password = "PackerBuilt!"
      type     = "ssh"
    }
  }
  depends_on = [rancher2_cluster.downstream_cluster]
}

