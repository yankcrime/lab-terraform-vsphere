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
