output "rancher_hosts" {
  value = module.rke-rancher.nodes
}

output "rancher_url" {
  value = "https://rancher.192.168.1.215.dnsify.me"
}

#output downstream_cluster_hosts {
#  value = local.downstream_cluster_nodes
#}

