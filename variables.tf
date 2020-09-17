variable "vsphere_user" {
  description = "vSphere username"
  default     = "Administrator@vsphere.local"
}

variable "vsphere_password" {
  description = "vSphere password"
  default     = ""
}

variable "vsphere_server" {
  description = "vSphere vCenter URL"
  default     = "vsphere.int.dischord.org"
}

variable "vsphere_datacenter" {
  description = "Target vSphere datacenter"
  default     = ""
}

variable "vsphere_network" {
  description = "vSphere network"
  default     = "vmGuests"
}

variable "vsphere_resource_pool" {
  description = "vSphere Resource Pool"
  default = ""
}

variable "vsphere_datastore" {
  description = "vSphere Datastore"
  default = "datastore1"
}

variable "admin_password" {
  description = "Rancher admin password"
  default     = "admin"
}

variable "vsphere_vm_template" {
  description = "Template to use for all VMs"
  default = "template_ubuntu2004_nocloudinit"
}

variable "ad_username" {
  description = "Active Directory service account used for lookups"
  default = ""
}

variable "ad_password" {
  description = "Active Directory password"
  default = ""
}

variable "domain" {
  description = "Domain suffix"
  default = "int.dischord.org"
}

variable "rancher_vip" {
  description = "IP address of VIP for Rancher"
  default     = "192.168.1.215"
}

variable "rancher_memory" {
  description = "How much memory to allocate to Rancher Server instances"
  default     = 4096
}

variable "rancher_disk" {
  description = "How much disk to allocate to Rancher Server instances"
  default = 20
}

variable "downstream_cluster_memory" {
  description = "How much memory to allocate to downstream cluster nodes"
  default = 2048
}

variable "downstream_cluster_disk" {
  description = "How much disk to allocate to downstream cluster nodes"
  default = 20
}

variable "ssh_user" {
  description = "Username for SSH access to VMs"
  default = "packerbuilt"
}

variable "ssh_password" {
  description = "Password for SSH access to VMs"
  default = "PackerBuilt!"
}

variable "keepalived_vip_interface" {
  description = "Interface to which the VIP should be assigned"
  default = "ens192"
}

variable "keepalived_vrrp_interface" {
  description = "Interface used for VRRP traffic"
  default = "ens192"
}

