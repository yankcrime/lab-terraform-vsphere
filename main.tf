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
    size  = var.rancher_disk
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "rancher${count.index}"
        domain    = var.domain
      }
      network_interface {
        ipv4_address = "${var.rancher_ip_range}${count.index}"
        ipv4_netmask = 24
      }
      ipv4_gateway    = var.network_gateway_ip
      dns_server_list = var.network_dns_servers
      dns_suffix_list = [var.domain]
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
      user     = var.ssh_user
      password = var.ssh_password
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
      user     = var.ssh_user
      password = var.ssh_password
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
  chart            = var.keepalived_helm_chart_folder
  namespace        = "vip-system"
  create_namespace = true

  set {
    name  = "keepalived.vipInterfaceName"
    value = var.keepalived_vip_interface
  }
  set {
    name  = "keepalived.vrrpInterfaceName"
    value = var.keepalived_vrrp_interface
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
  version          = var.rancher_version
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
  servers                         = var.ad_server
  tls                             = false
  port                            = 389
  service_account_username        = var.ad_username
  service_account_password        = var.ad_password
  default_login_domain            = var.ad_default_login_domain
  user_search_base                = var.ad_user_search_base
  group_search_base               = var.ad_group_search_base
  nested_group_membership_enabled = true
}

