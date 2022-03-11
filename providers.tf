provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "helm" {
  kubernetes {
    config_path = local_file.kube_cluster_yaml.filename
  }
}

provider "rancher2" {
  alias = "bootstrap"

  api_url = "https://rancher.${var.rancher_vip}.dnsify.me"
  bootstrap = true
  insecure = true
}

provider "rancher2" {
  api_url = rancher2_bootstrap.admin.url
  token_key = rancher2_bootstrap.admin.token
  insecure = true
}

provider "kubernetes" {
  config_path = local_file.kube_cluster_yaml.filename
}
