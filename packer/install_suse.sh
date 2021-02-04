# Apply updates and cleanup
#
zypper -n install -y --type pattern devel_basis
zypper -n install -y open-vm-tools growpart insserv-compat cloud-init \
	cairo-devel python-devel python3-devel docker

pip install -U pip
pip install pycairo

# Disable swap - generally recommendeded for K8s
#
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reset the machine-id value. This has known to cause issues with DHCP
#
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Reset any existing cloud-init state
#
systemctl enable cloud-init
cloud-init clean -s -l

# Enable Docker
systemctl enable docker

# Add upstream cloud-init-vmware-guestinfo
#
curl -sSL https://raw.githubusercontent.com/vmware/cloud-init-vmware-guestinfo/master/install.sh | sh -

# Disable cloud-init's handling of the network as causes intermittent issues
# with open-vm-tools handling of network configuration
#
echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99-disable-cloudinit-networking.cfg

# Cheat VMware Tools
#
sed -i '1s/^/suse enterprise server 15\n/' /etc/issue

# Cleanup
#
zypper -n rm -u wallpaper-branding sound-theme-freedesktop || true # don't fail if zypper fails (because it does sometimes)
zypper -n clean --all
rm -f /etc/udev/rules.d/70-persistent-net.rules;
touch /etc/udev/rules.d/75-persistent-net-generator.rules;

