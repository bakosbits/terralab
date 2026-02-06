#!/usr/bin/bash
set -o errexit   # Stop on error
set -o nounset   # Stop if you use an undefined variable

export DEBIAN_FRONTEND=noninteractive

# Add Docker's official GPG key:
sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repo to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Add Hashicorp repo
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install cloud-init, cloud-utilsdocker, nomad, consul
sudo apt-get update
sudo apt-get install -y cloud-init cloud-utils

# Disable cloud-init until were ready for it
sudo touch /etc/cloud/cloud-init.disabled

# Sanitize
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
sudo truncate -s 0 /etc/hostname
sudo rm -rf /var/lib/dhcp/dhclient.*

# Cleanup tmp
sudo find /tmp -type f -atime +10 -delete

eject -r

# Finish
exit 0