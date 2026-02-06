# Cluster Infrastructure

This directory contains Terraform configurations for deploying the Consul/Nomad cluster infrastructure on Proxmox.

## Overview

The cluster module provisions:

- **Manager Nodes**: Consul/Nomad servers (default: 3 nodes)
- **Worker Nodes**: Consul/Nomad clients (default: 3 nodes)
- **Cloud-init**: Automated node configuration
- **Networking**: Static IP assignments and DNS configuration

## Architecture

### Manager Nodes

- Run Consul in server mode (form consensus)
- Run Nomad in server mode (schedule workloads)
- Default specs: 4 cores, 8GB RAM, 8GB disk
- HA requires 3 or 5 nodes (odd number for quorum)

### Worker Nodes

- Run Consul in client mode
- Run Nomad in client mode (execute workloads)
- Default specs: 12 cores, 64GB RAM, 30GB disk
- Can scale horizontally as needed

## Files

| File | Purpose |
|------|---------|
| [`provider.tf`](provider.tf) | Proxmox provider configuration |
| [`variables.tf`](variables.tf) | Input variable declarations |
| [`cluster_nodes.tf`](cluster_nodes.tf) | Node list generation logic |
| [`proxmox_vm.tf`](proxmox_vm.tf) | VM resource definitions |
| [`cloud_init.tf`](cloud_init.tf) | Cloud-init configuration templates |
| `cluster.auto.tfvars` | Variable values (create from example) |
| `templates/*.tpl` | Consul/Nomad configuration templates |

## Prerequisites

1. **Packer templates built** (IDs: 9000, 9001, 9002)
2. **Terraform** >= 1.6.0 installed
3. **Proxmox cluster** accessible
4. **Network** range available for cluster nodes

## Configuration

### Create Variable File

Create `cluster.auto.tfvars` from the example provided. Key variables:

```hcl
provider_vars = {
  proxmox_url      = "https://<ip_address>:8006"
  proxmox_user     = "root@pam"
  proxmox_password = "your-password"
}

global = {
  cidr             = "192.168.100.0/24" # Network range example
  dns1             = "192.168.100.1"    # Primary DNS example
  ciuser           = "your-user"        # VM user
  cipassword       = "your-password"    # VM password
  sshkeys          = "ssh-rsa AAAA..."  # SSH public key
}

manager = {
  count  = 3  # Number of managers (1, 3, or 5)
  offset = 71 # Starting IP offset
  # ... other specs
}

worker = {
  count  = 3  # Number of workers
  offset = 81 # Starting IP offset
  # ... other specs
}
```

### Network Planning

The `cluster_nodes.tf` uses the CIDR and offset to assign IPs:

- Manager nodes: `cidrhost(cidr, offset + index)`
  - manager01: 192.168.100.71
  - manager02: 192.168.100.72
  - manager03: 192.168.100.73

- Worker nodes: `cidrhost(cidr, offset + index)`
  - worker01: 192.168.100.81
  - worker02: 192.168.100.82
  - worker03: 192.168.100.83

Adjust `cidr` and `offset` values to match your network.

## Deployment

### Initialize Terraform

```bash
make init-cluster
# or
cd terraform/cluster && terraform init
```

### Plan Deployment

```bash
make plan-cluster
# or
cd terraform/cluster && terraform plan
```

### Deploy Cluster

```bash
make deploy-cluster
# or
cd terraform/cluster && terraform apply
```

### Verify Deployment

```bash
# SSH into a manager node
ssh your-user@<ip_address>

# SSH into a worker node

# Check Consul cluster
consul members

# Check Nomad cluster
nomad server members
nomad node status
```

## Cloud-init Configuration

Cloud-init templates configure the nodes at boot:

### Manager Nodes

- Hostname configuration
- Network setup (static IP)
- Consul server configuration
- Nomad server configuration
- Service startup

Templates:
- [`templates/consul_manager.tpl`](templates/consul_manager.tpl)
- [`templates/nomad_manager.tpl`](templates/nomad_manager.tpl)

### Worker Nodes

- Hostname configuration
- Network setup (static IP)
- Consul client configuration
- Nomad client configuration
- Docker runtime
- Service startup

Templates:
- [`templates/consul_worker.tpl`](templates/consul_worker.tpl)
- [`templates/nomad_worker.tpl`](templates/nomad_worker.tpl)

## Customization

### Scaling Nodes

Edit `cluster.auto.tfvars`:

```hcl
manager = {
  count = 5  # Scale to 5 managers
  # ...
}

worker = {
  count = 6  # Scale to 6 workers
  # ...
}
```

Then apply changes:

```bash
terraform apply
```

### Adjusting Resources

Modify per-node resources in `cluster.auto.tfvars`:

```hcl
worker = {
  cores     = 16    # More CPU
  memory    = 98304 # 96GB RAM
  disk_size = 100   # 100GB disk
  # ...
}
```

### Proxmox Placement

Nodes are distributed across Proxmox hosts using modulo:

```hcl
target_node = var.pve_nodes[i % length(var.pve_nodes)]
```

Edit `pve_nodes` in `variables.tf` or override in `.tfvars`:

```hcl
pve_nodes = ["pve01", "pve02", "pve03", "pve04"]
```

### Storage Configuration

Update storage pools in `vm` variable:

```hcl
vm = {
  storage            = "your-storage"  # VM disk storage
  cloud_init_storage = "your-storage"  # Cloud-init storage
  # ...
}
```

## Consul Configuration

### Bootstrap Process

1. First manager starts Consul in bootstrap-expect mode
2. Waits for quorum (count/2 + 1 servers)
3. Forms cluster and elects leader
4. Additional managers join the cluster

### ACLs

If using Consul ACLs:

1. Bootstrap ACL system on first manager:
   ```bash
   consul acl bootstrap
   ```

2. Save the SecretID token
3. Configure in services terraform

### Encryption

Consul uses gossip encryption. Generate a key:

```bash
consul keygen
```

Add to cloud-init templates or use Vault.

## Nomad Configuration

### Bootstrap Process

1. Nomad servers form consensus (requires quorum)
2. Leader is elected
3. Clients connect to servers
4. Workloads can be scheduled

### ACLs

Bootstrap Nomad ACLs:

```bash
nomad acl bootstrap
```

Save the Secret ID for provider authentication.

### CSI Plugins

Worker nodes are configured to run CSI plugins for storage:

- NFS CSI plugin (via storage-controller and storage-node jobs)
- Allows dynamic volume provisioning

## Troubleshooting

### VMs Don't Start

- Verify template IDs exist (9001, 9002)
- Check Proxmox storage availability
- Ensure network bridge exists (`vmbr2`)
- Review Proxmox task log

### Consul Won't Form Cluster

- Check network connectivity between nodes
- Verify firewall rules (ports 8300-8302, 8500, 8600)
- Review consul logs: `journalctl -u consul`
- Ensure odd number of servers

### Nomad Clients Not Joining

- Verify Nomad servers are healthy
- Check network connectivity
- Review nomad logs: `journalctl -u nomad`
- Verify cloud-init ran successfully: `cloud-init status`

### SSH Access Issues

- Verify SSH key in `sshkeys` variable
- Check `ciuser` and `cipassword` are correct
- Try password authentication first
- Check VM console in Proxmox

### Cloud-init Failures

```bash
# Check cloud-init status
sudo cloud-init status

# View cloud-init logs
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Re-run cloud-init (for testing)
sudo cloud-init clean
sudo cloud-init init
```

## State Management

Terraform state is stored locally by default. For team environments:

### Remote State (Recommended)

Configure remote backend in `provider.tf`:

```hcl
terraform {
  backend "consul" {
    address = "consul.example.com:8500"
    path    = "terraform/cluster"
  }
}
```

Or use S3, GCS, Azure Storage, etc.

### State Backup

```bash
# Backup state
cp terraform.tfstate terraform.tfstate.backup-$(date +%Y%m%d)

# Before major changes
terraform state pull > state-backup.json
```

## Maintenance

### Updating Cluster

```bash
# Pull latest changes
git pull

# Review changes
terraform plan

# Apply updates
terraform apply
```

### Destroying Cluster

⚠️ **Warning**: This destroys all VMs and data!

```bash
terraform destroy
```

Or selectively destroy:

```bash
# Destroy only workers
terraform destroy -target=proxmox_vm_qemu.worker

# Destroy specific node
terraform destroy -target=proxmox_vm_qemu.manager[0]
```

## Next Steps

After cluster deployment:

1. Verify Consul cluster health
2. Verify Nomad cluster health
3. Configure ACLs (if using)
4. Proceed to [Services Deployment](../services/README.md)

## Reference

- [Terraform Proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Consul Documentation](https://www.consul.io/docs)
- [Nomad Documentation](https://www.nomadproject.io/docs)
- [Cloud-init Documentation](https://cloudinit.readthedocs.io/)
