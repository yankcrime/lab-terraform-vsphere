output "nodes" {
  value = vsphere_virtual_machine.vm.*.name
}

output "ip_addresses" {
  value = vsphere_virtual_machine.vm.*.default_ip_address
}

