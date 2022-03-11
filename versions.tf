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
      source  = "rancher/rancher2"
      version = "1.22.2"
    }
    rke = {
      source  = "rancher/rke"
      version = "1.3.0"
    }
    vsphere = {
      source = "hashicorp/vsphere"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.8.0"
    }
  }
  required_version = ">= 1.1"
}
