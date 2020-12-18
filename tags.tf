resource "vsphere_tag_category" "roles" {
  name        = "roles"
  cardinality = "MULTIPLE"
  description = "Roles"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "controlplane" {
  name        = "controlplane"
  category_id = vsphere_tag_category.roles.id
  description = "RKE controlplane role"
}

resource "vsphere_tag" "etcd" {
  name        = "etcd"
  category_id = vsphere_tag_category.roles.id
  description = "RKE etcd role"
}

resource "vsphere_tag" "worker" {
  name        = "worker"
  category_id = vsphere_tag_category.roles.id
  description = "RKE worker role"
}
