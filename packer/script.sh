# Apply updates and cleanup Apt cache
#
apt-get update ; apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y clean

# Disable swap - generally recommendeded for K8s
#
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reset the machine-id value. This has known to cause issues with DHCP
#
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Fixes for https://kb.vmware.com/s/article/56409
#
sed -i '/^D/s/^/#/' /usr/lib/tmpfiles.d/tmp.conf
sed -i '0,/^\[Unit\]/a After=dbus.service' /lib/systemd/system/open-vm-tools.service

# Reset any existing cloud-init state
#
cloud-init clean -s -l

# Add cloud-init-vmware-guestinfo
#
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -

# Install Docker
#
curl https://releases.rancher.com/install-docker/19.03.sh | sh

# Disable cloud-init's handling of the network as causes intermittent issues
# with open-vm-tools handling of network configuration
#
echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-cloudinit-networking.cfg
