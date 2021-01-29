terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    rancher2 = {
      source = "rancher/rancher2"
      version = "1.11.0"
    }
    rke = {
      source  = "rancher/rke"
      version = "1.1.7"
    }
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
  required_version = ">= 0.13"
}
