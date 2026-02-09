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

Configuration is managed via a file named `cluster.auto.tfvars`. Ther eis an example [HERE] This file is not checked into source control and should contain all your environment-specific variables.

### `cluster.auto.tfvars`

This file should contain a single `env` variable of type `map(any)`. There is a complete example with placeholder values [HERE](https://github.com/bakosbits/terralab/blob/main/terraform/services/examples/auto.tfvars.example)


### Node Definitions

The cluster nodes (managers and workers) are defined in `cluster_nodes.tf`. You can customize the number of nodes, their roles, and their resources (CPU, memory, disk) by modifying this file. This allows you to easily scale your cluster up or down.

## Deployment

You can use the [`Makefile`](https://github.com/bakosbits/terralab/blob/main/Makefile) in the root of the project to deploy the cluster.

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
