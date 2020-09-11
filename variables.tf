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

variable "admin_password" {
  description = "Rancher admin password"
  default     = "admin"
}

variable "ad_username" {
  description = "Active Directory service account used for lookups"
  default = ""
}
variable "ad_password" {
  description = "Active Directory password"
  default = ""
}

variable "rancher_vip" {
  description = "IP address of VIP for Rancher"
  default     = "192.168.1.215"
}

variable "rancher_memory" {
  description = "How much memory to allocate to Rancher Server instances"
  default     = 4096
}


