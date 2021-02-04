# lab-terraform-vsphere

This repository contains scratch code that's used in my own personal lab for development and test of various features related to Rancher and RKE.  It's not necessarily good quality Terraform code by any stretch of the imagination.

This repo contains everything I need to quickly spin up the following in my personal vSphere environment:

* Three nodes for Rancher Server
* A three-node Kubernetes deployment via RKE
* keepalived to provide a VIP for Rancher (via [this project](https://github.com/janeczku/keepalived-ingress-vip.git))
* cert-manager
* Rancher on the above cluster

It then optionally configures Rancher with Active Directory for authentication and bootstraps a downstream cluster (by default with one node as controlplane / etcd and one as a worker) using the custom node driver.

To make this work it also contains the Packer configuration for building an operating system image based on openSUSE Leap 15.2 and suitable for use by RKE.

This image makes use of [cloud-init](https://cloudinit.readthedocs.io/en/latest) to perform some OS customisation on boot.  You will need to update the userdata template that's used as part of VM initialisation (in [modules/nodes/templates](modules/nodes/templates)) to include your own SSH public key, for example.
