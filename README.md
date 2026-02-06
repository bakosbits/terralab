# TerraLab

Infrastructure as Code (IaC) project for deploying a Consul/Nomad cluster on Proxmox using Packer and Terraform.

## Overview

TerraLab automates the creation and configuration of a highly available service mesh using HashiCorp Consul and Nomad on Proxmox VE. The project is divided into two main phases:

1. **Image Building (Packer)**: Creates base VM templates with pre-configured software
2. **Infrastructure Deployment (Terraform)**: Provisions cluster nodes and deploys services

## Architecture

The infrastructure consists of:

- **Manager Nodes**: Run Consul and Nomad in server mode (typically 3 nodes for HA)
- **Worker Nodes**: Run Consul and Nomad in client mode, execute workloads
- **Services**: 40+ containerized services including:
  - Core infrastructure (Traefik, CoreDNS, Keepalived)
  - Data services (PostgreSQL, MongoDB, InfluxDB)
  - Media services (Jellyfin, Plex, Sonarr, Radarr)
  - Home automation (Home Assistant, MQTT)
  - Monitoring (Prometheus, Grafana, Loki)
  - And many more...

## Project Structure

```
.
├── packer/                      # VM template building
│   ├── base/                    # Base Debian template
│   ├── manager/                 # Manager node template
│   ├── worker/                  # Worker node template
│   └── variables.pkr.hcl        # Common Packer variables
├── terraform/
│   ├── cluster/                 # Cluster infrastructure
│   └── services/                # Service deployments
└── Makefile                     # Build automation
```

## Prerequisites

- **Proxmox VE** cluster
- **Packer** (>= 1.9.0)
- **Terraform** (>= 1.6.0)
- **Nomad CLI** (for job validation)
- Debian 13.3.0 ISO uploaded to Proxmox

## Quick Start

### 1. Configure Variables

Create `packer/packer.pkrvars.hcl`:
```hcl
proxmox_url      = "https://your-proxmox:8006"
proxmox_user     = "root@pam"
proxmox_password = "your-password"
proxmox_node     = "pve01"
ssh_username     = "your-user"
ssh_password     = "your-password"
```

### 2. Build VM Templates

```bash
# Build all templates
make build-all

# Or build individually
make build-base
make build-manager
make build-worker
```

### 3. Deploy Cluster

```bash
# Initialize Terraform
make init-cluster

# Plan deployment
make plan-cluster

# Deploy cluster
make deploy-cluster
```

### 4. Deploy Services

```bash
# Initialize Terraform
make init-services

# Plan service deployment
make plan-services

# Deploy services
make deploy-services
```

## Available Make Targets

| Target | Description |
|--------|-------------|
| `help` | Show all available targets |
| `build-base` | Build base VM template |
| `build-manager` | Build manager node template |
| `build-worker` | Build worker node template |
| `build-all` | Build all templates sequentially |
| `init-cluster` | Initialize Terraform for cluster |
| `init-services` | Initialize Terraform for services |
| `plan-cluster` | Create Terraform plan for cluster |
| `plan-services` | Create Terraform plan for services |
| `deploy-cluster` | Apply Terraform plan for cluster |
| `deploy-services` | Apply Terraform plan for services |
| `format` | Format Terraform and Nomad job files |
| `validate-jobs` | Validate all Nomad job specifications |

## Documentation

- [Packer Documentation](packer/README.md) - VM template building
- [Cluster Documentation](terraform/cluster/README.md) - Cluster infrastructure
- [Services Documentation](terraform/services/README.md) - Service deployment

## Network Configuration

Default network configuration:
- **Cluster CIDR**: 192.168.1.0/24
- **Manager Nodes**: 192.168.1.71-73
- **Worker Nodes**: 192.168.1.81-83
- **VIP (Keepalived)**: 192.168.1.2

These can be customized in the respective `.tfvars` files.

## Security Notes

⚠️ **Important**: The example configuration files contain placeholder credentials. Before deploying:

1. Replace all default passwords with strong, unique passwords
2. Generate new SSH keys and update `sshkeys` variable
3. Create new Consul/Nomad ACL tokens
4. Secure sensitive `.tfvars` files (add to `.gitignore`)
5. Use a secrets management solution (Vault, etc.) for production

## Troubleshooting

### Packer Build Fails
- Verify Proxmox credentials and node name
- Check that the Debian ISO exists at the specified path
- Ensure HTTP port 8200 is available for preseed serving

### Terraform Apply Fails
- Verify Proxmox API connectivity
- Check that VM templates exist (from Packer builds)
- Ensure sufficient storage and resources are available

### Services Won't Start
- Check Nomad logs: `nomad job status <job-name>`
- Verify CSI volumes are created
- Ensure required environment variables are set

## Contributing

1. Format code: `make format`
2. Validate jobs: `make validate-jobs`
3. Test changes in a non-production environment first

## License

See [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with:
- [HashiCorp Packer](https://www.packer.io/)
- [HashiCorp Terraform](https://www.terraform.io/)
- [HashiCorp Consul](https://www.consul.io/)
- [HashiCorp Nomad](https://www.nomadproject.io/)
- [Proxmox VE](https://www.proxmox.com/)
