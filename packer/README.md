# Packer Image Building

This directory contains the Packer configuration for building the virtual machine images used in the homelab.

## Image Types

There are three types of images built with Packer:

1.  **`base`**: This is the base image for all nodes in the cluster. It includes common packages, configurations, and hardening.
2.  **`manager`**: This image is built on top of the `base` image and is specifically for the Nomad and Consul server nodes. It includes the necessary binaries and configurations to run in server mode.
3.  **`worker`**: This image is also built on top of the `base` image and is for the Nomad client nodes. It includes the necessary binaries and configurations to run in client mode.

## Build Process

The build process for each image is defined in its respective directory (`base/`, `manager/`, `worker/`). The process generally involves:

1.  **Source**: A Proxmox ISO is used as the source for the image.
2.  **Provisioning**: A `provision.sh` script is executed to install software, configure the OS, and prepare the image for use in the cluster.
3.  **Post-processing**: The final image is converted into a Proxmox template.

## How to Build

### Prerequisites

- [Packer](https://www.packer.io/intro) installed.
- A `packer.pkrvars.hcl` file in this directory with the following variables:

```hcl
env = {
  proxmox_url      = "https://proxmox.example.com:8006/api2/json"
  proxmox_user     = "user@pam"
  proxmox_password = "password"
  proxmox_node     = "node01"
  ssh_username     = "your_user"
  ssh_password     = "your_password"
}
```

### Building Images

You can use the `Makefile` in the root of the project to build the images.

- **Build all images:**

  ```bash
  make build-all
  ```

- **Build a specific image (e.g., `manager`):**

  ```bash
  make build-manager
  ```

This will create Proxmox templates that can then be used by Terraform to provision the cluster.
