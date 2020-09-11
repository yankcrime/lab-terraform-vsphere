data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_resource_pool" "pool" {
  name          = "esxi01.int.dischord.org/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "template_ubuntu2004_nocloudinit"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "rancher_cluster" {
  count        = 3
  name         = "rancher${count.index}"
  datastore_id = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = var.rancher_memory

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
        host_name = "rancher${count.index}"
        domain    = "int.dischord.org"
      }
      network_interface {
        ipv4_address = "192.168.1.21${count.index}"
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

resource rke_cluster "rancher" {
  ssh_agent_auth = true

  dynamic nodes {
    for_each = vsphere_virtual_machine.rancher_cluster
    content {
      address           = vsphere_virtual_machine.rancher_cluster[nodes.key].default_ip_address
      hostname_override = vsphere_virtual_machine.rancher_cluster[nodes.key].name
      user              = "packerbuilt"
      role              = ["controlplane", "etcd", "worker"]
    }
  }
  depends_on = [vsphere_virtual_machine.rancher_cluster]
}

resource "local_file" "kube_cluster_yaml" {
  filename = "${path.root}/kube_config_cluster.yml"
  content  = rke_cluster.rancher.kube_config_yaml
}

resource "helm_release" "keepalived" {
  name             = "keepalived-ingress-vip"
  chart            = "../../../keepalived-ingress-vip/chart"
  namespace        = "vip-system"
  create_namespace = true

  set {
    name  = "keepalived.vipInterfaceName"
    value = "ens192"
  }
  set {
    name  = "keepalived.vrrpInterfaceName"
    value = "ens192"
  }
  set {
    name  = "keepalived.vipAddressCidr"
    value = "${var.rancher_vip}/24"
  }
  set {
    name  = "pod.replicas"
    value = length(vsphere_virtual_machine.rancher_cluster)
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  repository       = "https://charts.jetstack.io"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "rancher" {
  name             = "rancher"
  chart            = "rancher"
  version          = "2.4.8"
  namespace        = "cattle-system"
  create_namespace = true
  repository       = "https://releases.rancher.com/server-charts/latest"

  set {
    name  = "hostname"
    value = "rancher.${var.rancher_vip}.dnsify.me"
  }

  depends_on = [
    helm_release.keepalived,
    helm_release.cert-manager
  ]
}

resource "null_resource" "wait_for_rancher" {
  provisioner "local-exec" {
    command = <<EOF
while [ "$${resp}" != pong ]; do
  resp=$(curl -sSk -m 2 --insecure "https://$${RANCHER_HOSTNAME}/ping")
  echo "Rancher response: $${resp}"
  if [ "$${resp}" != "pong" ]; then
    sleep 10
  fi
done
EOF

    environment = {
      RANCHER_HOSTNAME = "rancher.${var.rancher_vip}.dnsify.me"
    }
  }
  depends_on = [
    helm_release.rancher
  ]
}

resource "rancher2_bootstrap" "admin" {
  provider = rancher2.bootstrap

  password  = var.admin_password
  telemetry = true

  depends_on = [
    null_resource.wait_for_rancher
  ]
}

resource "rancher2_auth_config_activedirectory" "activedirectory" {
  servers                         = ["192.168.1.121"]
  tls                             = false
  port                            = 389
  service_account_username        = var.ad_username
  service_account_password        = var.ad_password
  default_login_domain            = "INT"
  user_search_base                = "dc=int,dc=dischord,dc=org"
  group_search_base               = "dc=int,dc=dischord,dc=org"
  nested_group_membership_enabled = true
}

