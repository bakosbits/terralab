# Terraform Cluster Deployment

This directory contains the Terraform code to provision the Nomad and Consul cluster on Proxmox.

## Architecture

This Terraform environment will create a cluster of virtual machines on Proxmox, configured to run Nomad and Consul. The cluster consists of two types of nodes:

- **Managers**: These nodes run the Nomad and Consul servers in server mode. They are responsible for managing the cluster state and scheduling jobs.
- **Workers**: These nodes run the Nomad client in client mode. They are responsible for running the actual jobs.

The provisioning process is as follows:

1.  **VM Creation**: Terraform creates the VMs in Proxmox by cloning the templates built by Packer.
2.  **Cloud-Init**: On first boot, `cloud-init` is used to configure each node. This includes:
    - Setting the hostname and network configuration.
    - Creating a user and setting up SSH access.
    - Writing the appropriate Nomad and Consul configuration files based on the node's role (manager or worker).
    - Enabling and starting the `nomad` and `consul` services.

## Configuration

## Configuration

Configuration is managed via a file named `cluster.auto.tfvars` in this directory. This file is not checked into source control and should contain all your environment-specific variables.

### `cluster.auto.tfvars`

This file should contain a single `env` variable of type `map(any)`. Here is a complete example with placeholder values:

```hcl
env = {
  # Proxmox API credentials
  proxmox_url      = "https://proxmox.example.com:8006/api2/json"
  proxmox_user     = "root@pam"
  proxmox_password = "your-password"

  # Proxmox node to provision on
  pve_nodes        = ["pve-node-1"]

  # VM settings
  vm = {
    full_clone         = true
    cpu_type           = "host"
    agent_enabled      = true
    bridge             = "vmbr0"
    network_model      = "virtio"
    storage            = "local-lvm"
    disk_interface     = "scsi0"
    disk_iothread      = true
    disk_discard       = true
    disk_ssd           = true
    cloudinit_interface = "eth0"
    cloud_init_storage = "local-lvm"
  }

  # Cloud-init settings
  ciuser             = "admin"
  cipassword         = "your-ci-password"
  sshkeys            = "ssh-rsa AAAA..."

  # Network settings
  internal_domain    = "homelab.local"
  cidr               = "192.168.1.0/24"
  dns1               = "192.168.1.1"

  # Cluster settings
  datacenter         = "dc1"
}
```

### Node Definitions

The cluster nodes (managers and workers) are defined in `cluster_nodes.tf`. You can customize the number of nodes, their roles, and their resources (CPU, memory, disk) by modifying this file. This allows you to easily scale your cluster up or down.

## Deployment

You can use the `Makefile` in the root of the project to deploy the cluster.

1.  **Initialize Terraform:**

    ```bash
    make init-cluster
    ```

2.  **Review the execution plan:**

    ```bash
    make plan-cluster
    ```

3.  **Apply the plan:**

    ```bash
    make deploy-cluster
    ```

This will provision the VMs and start the Nomad and Consul cluster. You can then access the Nomad UI to start deploying services.
