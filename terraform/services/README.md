# Terraform Services Deployment

This directory contains the Terraform code for deploying services on top of the Nomad cluster.

## Architecture

This Terraform environment manages the lifecycle of services running on the Nomad cluster. It uses a combination of Nomad jobs for running the services and Consul's Key-Value (KV) store for managing their configurations.

### Service Deployment Order

To ensure that dependencies are met, services are deployed in a specific order. This is defined in `nomad_jobs.tf` by creating dependencies between groups of services. The deployment order is as follows:

1.  **Storage Services**: Services that provide storage to other services.
2.  **Data Services**: Databases and other data-related services.
3.  **Network Services**: Services related to networking, such as reverse proxies and DNS.
4.  **Logging Services**: Services for log aggregation and analysis.
5.  **Core Services**: Core infrastructure services.
6.  **Media Services**: Services for media streaming and management.
7.  **Standard Services**: All other services.

### Configuration Management

Service configurations are managed using a combination of Terraform variables and Consul KV.

- **Nomad Jobs**: The Nomad job files are located in the `nomad_jobs/` directory. They are written in HCL and are templated using Terraform's `templatefile` function. This allows for dynamic values to be inserted into the job files at runtime.
- **Consul KV**: The configurations for the services themselves are stored in Consul KV. These configurations are also templated and are located in the `consul_kv/` directory. The Nomad jobs are configured to read their configuration from Consul KV, which allows for centralized configuration management and easy updates without redeploying the jobs.

## Configuration

All service definitions, configurations, and variables are managed through `.auto.tfvars` files in this directory. This allows for a modular and easily manageable approach to service deployment.

### `services.auto.tfvars`

This is the main file for defining your services. It contains the maps for `nomad_jobs`, `consul_kv`, `nomad_vars`, and `volumes`.

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
    access_mode = "multi-node-multi-writer"
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
3.  **Define the Service in `services.auto.tfvars`**:
    - Add your service to the appropriate group in the `nomad_jobs` map.
    - If you added Consul KV configs, create an entry in the `consul_kv` map.
    - If your service needs a volume, add it to the `volumes` map.
4.  **Deploy**: Run `make deploy-services`.
