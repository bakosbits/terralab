# Terraform Services Deployment

This directory contains the Terraform code for deploying services on top of the Nomad cluster.

## Architecture

This Terraform environment manages the lifecycle of services running on the Nomad cluster. It uses a combination of Nomad jobs for running the services and Consul's Key-Value (KV) store for managing their configurations.

### Service Deployment Order

To ensure that dependencies are met, services are deployed in a controlled manner using job groups. This is defined in [nomad_jobs.auto.tfvars](https://github.com/bakosbits/terralab/blob/main/terraform/services/examples/nomad_jobs.auto.tfvars.example) by creating dependencies between groups of services. Jobs can be group in one of the seven categories. This job grouping helps manage the velocity behind jobs being deployed:

1.  **Initial Services**: Services that provide storage or other key services.
2.  **Data Services**: Databases and other data-related services.
3.  **Network Services**: Services related to networking, such as reverse proxies.
4.  **Logging Services**: Services for log aggregation and analysis.
5.  **Core Services**: Core infrastructure services.
6.  **Media Services**: Services for media streaming and management.
7.  **Final Services**: All other services.

### Configuration Management

Service configurations are managed using a combination of Terraform variables and Consul KV.

- **Nomad Jobs**: The Nomad job files are located in the `nomad_jobs/` directory. They are written in HCL and are templated using Terraform's `templatefile` function. This allows for dynamic values to be inserted into the job files at runtime.

- **Consul KV**: The configurations for the services that require additional files are stored in Consul KV. These configurations are also templated and are located in the `consul_kv/` directory. The Nomad jobs are configured to read their configuration from Consul KV, which allows for centralized configuration management and easy updates without redeploying the jobs.

## Configuration

All service definitions, configurations, and variables are managed through `*.auto.tfvars` files in this directory. This allows for a modular and easily manageable approach to service deployment. Complete working examples of tfvars are located in the [examples](https://github.com/bakosbits/terralab/tree/main/terraform/services/examples) directory

### `*.auto.tfvars`

There are a total of 5 tfvars files used to define services
  1. services.auto.tfvars:   This holds variables used in terraform configuration and template vars
  2. nomad_jobs.auto.tfvars: This holds a map that defines nomad jobs. It's consumed by resources in nomad_jobs.tf
  3. consul_kv.auto.tfvars:  This hold a map that defines Consul key=value pairs. It's consumed by resources in consul_kv.tf
  4. nomad_vars.auto.tfvars: This hold a map that defines Nomad Variables. It's consumed by resources in nomad_vars.tf
  5. volumes.auto.tfvars:    This holds a map that defines CSI and Dynamic Host volumes. It's consumed by nomad_volumes.tf    

These five files work together to define your deployment without having to alter the Terraform code. They give you the following capabilities:

* Alter vm resources
* Increase/decrease the size of the cluster
* Choose from CSI or dynamic host volumes
* Define the jobs that run in your lab
* Manage job specifics such as Docker image version, cpu, ram, etc consumed by a job
* Manage sensitive variables securely
* Manage job assets without have to redeploy the job

### `tfvars` snippets

#### `nomad_jobs`

This map defines the Nomad jobs to be deployed. The jobs are grouped into categories that are deployed in a specific order.

```hcl
nomad_jobs = {
  storage_services = {
    "minio" = {
      version = "latest"
      cpu     = 500
      ram     = 512
    }
  }
  data_services = {
    "influxdb" = {
      version = "2.7"
      cpu     = 500
      ram     = 1024
    }
  }
  # ... other service groups
}
```

#### `consul_kv`

This map defines the configuration files to be stored in Consul KV.

```hcl
consul_kv = {
  "traefik" = {
    path_prefix = "terralab/traefik/"
    filenames   = ["traefik.yaml", "dynamic.yaml"]
  }
  "loki" = {
    path_prefix = "terralab/loki/"
    filenames   = ["loki.yaml"]
  }
}
```

#### `nomad_vars`

This map is used for Nomad variables, such as secrets.

```hcl
nomad_vars = {
  "secrets" = {
    vars = {
      "my_secret" = "super-secret-value"
    }
  }
}
```

#### `volumes`

This map defines the CSI volumes to be created for your services.

```hcl
volumes = {
  "loki" = {
    volume_id   = "loki"
    external_id = "loki"
    access_mode = "single-node-writer"
  }
}
```

## Deployment

You can use the `Makefile` in the root of the project to deploy the services.

1.  **Initialize Terraform:**

    ```bash
    make init-services
    ```

2.  **Review the execution plan:**

    ```bash
    make plan-services
    ```

3.  **Apply the plan:**

    ```bash
    make deploy-services
    ```

This will deploy all the services defined in your `services.auto.tfvars` file.

## How to Add a New Service

1.  **Create a Nomad Job File**: In `nomad_jobs/`, create a new `.hcl` file for your service.
2.  **Add Configuration to Consul KV (Optional)**: If your service needs configuration files, add them to a new subdirectory in `consul_kv/`.
3.  **Define the Service in `nomad_jobs.auto.tfvars`**:
    - Add your service to the appropriate group in the `nomad_jobs` map.
    - If you added Consul KV configs, create an entry in the `consul_kv` map.
    - If your service needs a volume, add it to the `volumes` map.
    - If you need to store env or sensitive data, add it to the `nomad_vars` map.
4.  **Deploy**: Run `make deploy-services`.
