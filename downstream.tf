resource "rancher2_cluster" "downstream_cluster" {
  name        = var.downstream_cluster_name
  description = var.downstream_cluster_description

  rke_config {
    kubernetes_version = var.downstream_kubernetes_version
    services {
      kube_api {
        secrets_encryption_config {
          enabled = true
        }
      }
    }
  }
}

module "rke-control" {
  source = "./modules/nodes"
  num    = var.num_control
  name   = "control"
  cpus   = var.control_cpus
  memory = var.control_memory

  template_uuid    = data.vsphere_virtual_machine.template.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  datastore_id = data.vsphere_datastore.datastore.id
  network_id   = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  domain_name = var.domain
  ssh_user    = var.ssh_user

  tags = [vsphere_tag.controlplane.id, vsphere_tag.etcd.id]
}

module "rke-worker" {
  source = "./modules/nodes"
  num    = var.num_worker
  name   = "worker"
  cpus   = var.worker_cpus
  memory = var.worker_memory

  template_uuid    = data.vsphere_virtual_machine.template.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  resource_pool_id = data.vsphere_resource_pool.pool.id

  datastore_id = data.vsphere_datastore.datastore.id
  network_id   = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  domain_name = var.domain
  ssh_user    = var.ssh_user

  tags = [vsphere_tag.worker.id]
}

resource "null_resource" "downstream_cluster_controlplane_deploy" {
  for_each = zipmap(module.rke-control.nodes, module.rke-control.ip_addresses)

  provisioner "remote-exec" {
    inline = ["${rancher2_cluster.downstream_cluster.cluster_registration_token.0["node_command"]} --controlplane --etcd"]
    connection {
      host        = each.value
      user        = var.ssh_user
      password    = var.ssh_password
      type        = "ssh"
      script_path = "~${var.ssh_user}/rke.sh"
    }
  }
  depends_on = [rancher2_cluster.downstream_cluster]
}

resource "null_resource" "downstream_cluster_worker_deploy" {
  for_each = zipmap(module.rke-worker.nodes, module.rke-worker.ip_addresses)

  provisioner "remote-exec" {
    inline = ["${rancher2_cluster.downstream_cluster.cluster_registration_token.0["node_command"]} --worker"]
    connection {
      host        = each.value
      user        = var.ssh_user
      password    = var.ssh_password
      type        = "ssh"
      script_path = "~${var.ssh_user}/rke.sh"
    }
  }
  depends_on = [rancher2_cluster.downstream_cluster]
}

