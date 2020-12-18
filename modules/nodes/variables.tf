variable "name" {
  default = ""
}

variable "num" {
  default = ""
}

variable "resource_pool_id" {
  default = ""
}

variable "datastore_id" {
  default = ""
}

variable "cpus" {
  description = "Number of CPUs to allocate to VM"
  default     = "2"
}

variable "memory" {
  description = "Amount of memory to allocate to VM in MB"
  default     = "2048"
}

variable "guest_id" {
  default = ""
}

variable "network_id" {
  description = "ID of network to attach VM to"
  default     = ""
}

variable "adapter_type" {
  description = "Type of NIC"
  default     = ""
}

variable "disk_size" {
  description = "Size of disk to allocate in GB"
  default     = 20
}

variable "template_uuid" {
  description = "UUID of template to clone VM from"
  default     = ""
}

variable "ipv4_address" {
  description = "IP address of machine"
  default     = ""
}

variable "ipv4_gateway" {
  description = "Default gateway"
  default     = ""
}

variable "dns_servers" {
  description = "List of DNS servers"
  default     = []
}

variable "host_name" {
  description = "Hostname for VM"
  default     = ""
}

variable "domain_name" {
  description = "Domain name for VM"
  default     = ""
}

variable "ssh_user" {
  default     = "packerbuilt"
  description = "SSH user for access to created VM"
}

variable "tags" {
  default = []
}
