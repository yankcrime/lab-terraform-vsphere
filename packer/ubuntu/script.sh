# Apply updates and cleanup Apt cache
apt-get update ; apt-get -y dist-upgrade

# Disable swap - generally recommended for K8s, but otherwise enable it for other workloads
echo "Disabling Swap"
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reset the machine-id value. This has known to cause issues with DHCP
#
echo "Reset Machine-ID"
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Reset any existing cloud-init state
#
echo "Reset Cloud-Init"
rm /etc/cloud/cloud.cfg.d/*.cfg
cloud-init clean -s -l

# Install Docker
#
curl https://releases.rancher.com/install-docker/20.10.sh | sh

# Disable cloud-init's handling of the network as causes intermittent issues
# with open-vm-tools handling of network configuration
#
echo 'datasource_list: [ VMware, None ]' > /etc/cloud/cloud.cfg.d/90_dpkg.cfg

# Cleanup
apt-get -y autoremove
apt-get -y clean

