output "rancher_hosts" {
  value = module.rke-rancher.nodes
}

output "rancher_url" {
  value = "https://rancher.${var.rancher_vip}.dnsify.me"
}

#output downstream_cluster_hosts {
#  value = local.downstream_cluster_nodes
#}

