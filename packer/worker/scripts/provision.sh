#!/usr/bin/bash
set -o errexit   # Stop on error
set -o nounset   # Stop if you use an undefined variable

export DEBIAN_FRONTEND=noninteractive

# Install docker, nomad, consul
sudo apt-get update
sudo apt-get install -y consul nomad docker-ce

# Configure consul and nomad
sudo rm /etc/consul.d/* /etc/nomad.d/*
sudo systemctl disable consul nomad

# Enable cloud-init
sudo rm -f /etc/cloud/cloud-init.disabled

# Disable root
sudo /usr/bin/passwd -l root
sudo sed -e 's/PermitRootLogin yes/#PermitRootLogin prohibit-password/' -i /etc/ssh/sshd_config

# Sanitize
sudo truncate -s 0 /etc/hostname
sudo truncate -s 0 /etc/machine-id
[ -f /var/lib/dbus/machine-id ] && sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Cleanup tmp
sudo find /tmp -type f -atime +10 -delete

# Finish
exit 0