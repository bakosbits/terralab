# Packer VM Templates

This directory contains Packer configurations for building Proxmox VM templates used in the TerraLab cluster.

## Overview

Packer automates the creation of three VM templates:

1. **base-tpl** (ID: 9000) - Base Debian installation
2. **manager-tpl** (ID: 9001) - Manager nodes with Consul/Nomad
3. **worker-tpl** (ID: 9002) - Worker nodes with Consul/Nomad

## Directory Structure

```
packer/
├── variables.pkr.hcl           # Common variables for all templates
├── packer.pkrvars.hcl          # Variable values (create from example)
├── base/                       # Base Debian template
│   ├── build.pkr.hcl          # Build configuration
│   ├── config.pkr.hcl         # Main template config
│   ├── source.pkr.hcl         # Proxmox source definition
│   ├── variables.pkr.hcl      # Base-specific variables
│   ├── http/
│   │   └── preseed.cfg        # Debian preseed for unattended install
│   └── scripts/
│       └── provision.sh       # Base provisioning script
├── manager/                    # Manager template
│   ├── build.pkr.hcl
│   ├── config.pkr.hcl
│   ├── source.pkr.hcl
│   ├── variables.pkr.hcl
│   └── scripts/
│       └── provision.sh       # Installs Consul/Nomad
└── worker/                     # Worker template
    ├── build.pkr.hcl
    ├── config.pkr.hcl
    ├── source.pkr.hcl
    ├── variables.pkr.hcl
    └── scripts/
        └── provision.sh       # Installs Consul/Nomad
```

## Prerequisites

- Packer >= 1.9.0
- Proxmox VE 7.x or 8.x
- Debian 13.3.0 netinst ISO uploaded to Proxmox storage
- Network connectivity from Packer machine to Proxmox

## Configuration

### 1. Create Variable File

Create `packer.pkrvars.hcl` from the example:

```hcl
proxmox_url      = "https://<ip_address>:8006"
proxmox_user     = "root@pam"
proxmox_password = "your-proxmox-password"
proxmox_node     = "pve01"
ssh_username     = "your-username"
ssh_password     = "your-password"
```

### 2. Verify ISO Location

Ensure the Debian ISO is available in Proxmox:
- Default path: `local:iso/debian-13.3.0-amd64-netinst.iso`
- Update [`source.pkr.hcl`](base/source.pkr.hcl:43) if using a different ISO

### 3. Adjust Storage Pools

Update storage pool names if different from defaults:
- **Disk storage**: `rbd` (Ceph)
- **Cloud-init storage**: `rbd` (base), `cephfs` (manager/worker)

Edit in respective `source.pkr.hcl` files.

## Building Templates

### Build All Templates (Sequential)

```bash
make build-all
```

This builds templates in order: base → manager → worker

### Build Individual Templates

```bash
# Build base template first
make build-base

# Then build manager template (depends on base)
make build-manager

# Then build worker template (depends on base)
make build-worker
```

### Manual Build Command

```bash
cd packer/base
packer build -var-file=../packer.pkrvars.hcl .
```

## Template Details

### Base Template (base-tpl)

- **VM ID**: 9000
- **OS**: Debian 13.3.0
- **Specs**: 2 cores, 2GB RAM, 6GB disk
- **Features**:
  - Minimal Debian installation
  - QEMU guest agent
  - Cloud-init enabled
  - Unattended install via preseed
  - Basic utilities and updates

**Build Time**: ~10-15 minutes

### Manager Template (manager-tpl)

- **VM ID**: 9001
- **Based on**: base-tpl (9000)
- **Additional Software**:
  - Consul (server mode capable)
  - Nomad (server mode capable)
  - Cloud-init for configuration

**Build Time**: ~5 minutes

### Worker Template (worker-tpl)

- **VM ID**: 9002
- **Based on**: base-tpl (9000)
- **Additional Software**:
  - Consul (client mode)
  - Nomad (client mode)
  - Docker runtime
  - Cloud-init for configuration

**Build Time**: ~5 minutes

## Template Configuration

### Network

- **Bridge**: `vmbr2`
- **Model**: `virtio`
- Network configuration is applied via cloud-init at VM creation time

### Storage

- **Controller**: virtio-scsi-single
- **Disk type**: SCSI
- **Features**: Discard, SSD emulation, IO thread

### Boot Process

1. Packer starts VM with Debian ISO
2. Preseed file served via HTTP (port 8200)
3. Debian performs unattended installation
4. Provisioning script runs
5. VM is cleaned and converted to template

## Provisioning Scripts

### Base Provisioning ([`base/scripts/provision.sh`](base/scripts/provision.sh))

- System updates
- Essential package installation
- Cloud-init configuration
- System hardening

### Manager/Worker Provisioning

- Installs Consul and Nomad binaries
- Configures (but doesn't enable) services
- Cloud-init will configure at boot time
- System sanitization (machine-id, hostname)

## Troubleshooting

### Build Hangs at Boot

- Check HTTP server accessibility (port 8200)
- Verify preseed file path
- Ensure Proxmox can reach Packer machine

### SSH Timeout

- Verify SSH credentials in `packer.pkrvars.hcl`
- Check VM console in Proxmox for errors
- Ensure firewall allows SSH (port 22)

### Template Not Created

- Check Packer output for errors
- Verify Proxmox API credentials
- Ensure VM ID is not already in use
- Check storage pool has sufficient space

### ISO Not Found

- Verify ISO exists: `local:iso/debian-13.3.0-amd64-netinst.iso`
- Check ISO is uploaded to correct storage
- Update `boot_iso.iso_file` in `source.pkr.hcl`

## Customization

### Change ISO Version

1. Upload new ISO to Proxmox
2. Update `boot_iso.iso_file` in [`base/source.pkr.hcl`](base/source.pkr.hcl:43)
3. Update preseed if needed for new version

### Modify Resources

Edit `source.pkr.hcl` in each template directory:

```hcl
cores  = 4        # CPU cores
memory = 4096     # RAM in MB
disk_size = "10G" # Disk size
```

### Add Software

Edit provisioning scripts in `scripts/provision.sh`:

```bash
# Install additional packages
sudo apt-get install -y package-name
```

### Change Network Bridge

Update in `source.pkr.hcl`:

```hcl
network_adapters {
  model  = "virtio"
  bridge = "vmbr0"  # Change bridge
}
```

## Security Considerations

- Store `packer.pkrvars.hcl` securely (add to `.gitignore`)
- Use separate Proxmox API user with minimal permissions
- Change default SSH passwords in templates
- Review and harden provisioning scripts
- Keep ISO images up to date with security patches

## Next Steps

After building templates:

1. Verify templates exist in Proxmox (IDs 9000, 9001, 9002)
2. Proceed to [Cluster Deployment](../terraform/cluster/README.md)
3. Configure cluster variables for Terraform

## Reference

- [Packer Documentation](https://www.packer.io/docs)
- [Proxmox Builder](https://www.packer.io/plugins/builders/proxmox)
- [Debian Preseed](https://www.debian.org/releases/stable/amd64/apb.html)
