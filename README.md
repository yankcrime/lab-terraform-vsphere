# lab-terraform-vsphere

🚨 This repository contains scratch code that's used in my own personal lab for development and test of various features related to Rancher and RKE.  It's not good quality Terraform code by any stretch of the imagination. 🚨

This repo contains everything I need to quickly spin up the following in my personal vSphere environment:

* Three nodes for Rancher Server
* A three-node Kubernetes deployment via RKE
* keepalived to provide a VIP for Rancher (via Helm using a local checkout of [this repo](https://github.com/janeczku/keepalived-ingress-vip.git))
* cert-manager
* Rancher on the above cluster

It then configures Rancher with Active Directory for authentication and bootstraps a four-node downstream cluster using the custom node driver.

To make this work, it also contains the Packer configuration for building a Ubuntu 20.04 image.  This is based on David Holder's work [here](https://github.com/David-VTUK/Rancher-Packer).

Instances are provisioned using SSH;  I burned far too much time trying to make cloud-init work with the Terraform vSphere provider without much luck, inevitably ending up with VMs that failed to properly initialise their networking as VMware Tools and cloud-init don't play nicely together.  As a result there's an awful hack of a shell script that does a poor job of configuring a VM on boot, doing things like expanding filesystems and injecting my SSH key.


