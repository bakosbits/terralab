# Terralab - A Homelab Project

This repository contains the infrastructure as code for a homelab environment built on Proxmox, Nomad, and Consul. The infrastructure is managed using Packer and Terraform.

## Project Structure

The project is divided into two main parts:

- **`packer/`**: This directory contains the Packer templates for building the virtual machine images for the cluster nodes.
- **`terraform/`**: This directory contains the Terraform code for provisioning the infrastructure and deploying services.

### Packer

The `packer/` directory is responsible for creating three different VM images:

- **`base`**: A base image with common tools and configurations.
- **`manager`**: An image for the Nomad and Consul server nodes.
- **`worker`**: An image for the Nomad client nodes.

### Terraform

The `terraform/` directory is split into two environments:

- **`cluster`**: This environment provisions the core cluster infrastructure, including the Proxmox VMs, networking, and cloud-init configurations for the Nomad and Consul cluster.
- **`services`**: This environment deploys various services on top of the Nomad cluster. Services are defined as Nomad jobs, and their configurations are managed using Consul's Key-Value store.

## Getting Started

### Prerequisites

- [Packer](https://www.packer.io/intro)
- [Terraform](https://www.terraform.io/intro)
- [Proxmox VE](https://www.proxmox.com/en/proxmox-ve)

### Installation

1.  **Clone the repository:**

    ```bash
    git clone <repository-url>
    cd terralab
    ```

2.  **Configure Packer variables:**

    Create a `packer.pkrvars.hcl` file in the `packer/` directory with your Proxmox credentials and other required variables.

3.  **Build the Packer images:**

    You can build all images at once or individually.

    ```bash
    # Build all images
    make build-all

    # Build a specific image (e.g., base)
    make build-base
    ```

4.  **Configure Terraform variables:**

    Create a `terraform.tfvars` file in `terraform/cluster` and `terraform/services` with your specific configuration.

5.  **Deploy the cluster:**

    ```bash
    # Initialize Terraform for the cluster
    make init-cluster

    # Review the plan
    make plan-cluster

    # Apply the plan
    make deploy-cluster
    ```

6.  **Deploy the services:**

    ```bash
    # Initialize Terraform for the services
    make init-services

    # Review the plan
    make plan-services

    # Apply the plan
    make deploy-services
    ```

## Makefile Commands

A `Makefile` is provided at the root of the project to simplify common tasks.

- `make help`: Show available commands.
- `make build-all`: Build all Packer images.
- `make build-<name>`: Build a specific Packer image (e.g., `make build-base`).
- `make init-cluster`: Initialize Terraform for the cluster.
- `make plan-cluster`: Create a Terraform plan for the cluster.
- `make deploy-cluster`: Deploy the cluster.
- `make init-services`: Initialize Terraform for the services.
- `make plan-services`: Create a Terraform plan for the services.
- `make deploy-services`: Deploy the services.
- `make format`: Format all Terraform and Nomad files.

## Architecture Diagram

*(Suggestion: You could add an architecture diagram here showing the relationships between Proxmox, the cluster nodes, and the services.)*

```
+-----------------+
|    Proxmox      |
| +-------------+ |
| | Manager VM  | |
| +-------------+ |
| +-------------+ |
| | Worker VM   | |
| +-------------+ |
| +-------------+ |
| | Worker VM   | |
| +-------------+ |
+-----------------+
```
