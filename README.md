# lab-terraform-vsphere

This repository contains scratch code that's used in my own personal lab for development and test of various features related to Rancher and RKE.  It's not necessarily good quality Terraform code by any stretch of the imagination.

This repo contains everything I need to quickly spin up the following in my personal vSphere environment:

* Three nodes for Rancher Server
* A three-node Kubernetes deployment via RKE
* keepalived to provide a VIP for Rancher (via [this project](https://github.com/janeczku/keepalived-ingress-vip.git))
* cert-manager
* Rancher on the above cluster

It then optionally configures Rancher with Active Directory for authentication and bootstraps a downstream cluster (by default with one node as controlplane / etcd and one as a worker) using the custom node driver.

To make this work it also contains the Packer configuration for building a Ubuntu 20.04 image.  This is based on David Holder's work [here](https://github.com/David-VTUK/Rancher-Packer).  This image also bakes in an SSH public key into the user that's used for provisioning (`packerbuilt` by default).  The reason for this is that I burned far too much time trying to make cloud-init work with the Terraform vSphere provider without much luck, inevitably ending up with VMs that failed to properly initialise their networking as VMware Tools and cloud-init really don't play nicely together. 
