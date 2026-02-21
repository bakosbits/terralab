# Terraform Services Deployment

This directory contains the Terraform code for deploying services on top of the Nomad cluster.

## Architecture

This Terraform environment manages the lifecycle of services running on the Nomad cluster. It uses a combination of Nomad jobs for running the services and Consul's Key-Value (KV) store for managing their configurations.

### Service Deployment Order

To ensure that dependencies are met, services are deployed in a controlled manner using job groups. This is defined in `nomad_jobs.auto.tfvars` by creating dependencies between groups of services. Jobs are grouped in three deployment tiers:

1.  **Primary**: Core infrastructure services that other services depend on (storage, databases, networking).
2.  **Secondary**: Services that depend on primary services but are dependencies for other services.
3.  **Tertiary**: Application services that depend on primary and secondary services.

### Configuration Management

Service configurations are managed using a combination of Terraform variables and Consul KV.

- **Nomad Jobs**: The Nomad job files are located in the `nomad_jobs/` directory. They are written in HCL and are templated using Terraform's `templatefile` function. This allows for dynamic values to be inserted into the job files at runtime.

- **Consul KV**: The configurations for the services that require additional files are stored in Consul KV. These configurations are also templated and are located in the `consul_kv/` directory. The Nomad jobs are configured to read their configuration from Consul KV, which allows for centralized configuration management and easy updates without redeploying the jobs.

## Configuration

Service definitions are managed through a combination of `*.auto.tfvars` files and auto-discovered directory structures. Complete working examples are located in the `examples/` directory.

### `*.auto.tfvars`

There are 3 tfvars files used to define services:
  1. **auto.tfvars**: General environment variables and template variables
  2. **nomad_jobs.auto.tfvars**: Defines nomad jobs grouped by deployment tier (primary, secondary, tertiary)
  3. **storage.auto.tfvars**: Defines storage type (host/CSI), mount configuration, and volumes

### Auto-Discovered Directories

Two directories are auto-discovered by Terraform using `fileset()` — no tfvars entries are needed:

  - **`consul_kv/{service}/{file}`**: Configuration files stored in Consul KV. All files in each service subdirectory are automatically discovered and templated with `local.vars`.
  - **`nomad_vars/{service}.tftpl`**: Nomad variables (secrets, environment variables). Each `.tftpl` file uses a `KEY : VALUE` line format and is templated with `local.vars`.

Together these give you the following capabilities:

* Alter vm resources
* Increase/decrease the size of the cluster
* Choose from CSI or dynamic host volumes
* Define the jobs that run in your lab
* Manage job specifics such as Docker image version, cpu, ram, etc consumed by a job
* Manage sensitive variables securely via templated nomad_vars
* Manage job assets without having to redeploy the job

### `tfvars` snippets

#### `nomad_jobs`

This map defines the Nomad jobs to be deployed. The jobs are grouped into categories that are deployed in a specific order.

```hcl
nomad_jobs = {
  primary = {
    jobs = {
      "storage_controller" = {
        version = "latest"
        cpu     = 500
        ram     = 512
      }
      "influxdb" = {
        version = "2.7"
        cpu     = 500
        ram     = 1024
      }
    }
  }
  secondary = {
    jobs = {
      "traefik" = {
        version = "3.0"
        cpu     = 250
        ram     = 256
      }
    }
  }
  # ... other deployment tiers
}
```

#### `consul_kv/` directory

Configuration files for Consul KV are auto-discovered from the `consul_kv/` directory. Create a subdirectory per service and place config files inside:

```
consul_kv/
  traefik/
    traefik.yaml
    dynamic.yaml
  loki/
    loki.yaml
```

Files are processed with `templatefile()` and can use variables from `local.vars` (e.g. `${domain}`).

#### `nomad_vars/` directory

Nomad variables (secrets, environment variables) are auto-discovered from `.tftpl` files in the `nomad_vars/` directory. Each file maps to a Nomad variable path at `nomad/jobs/{filename}`:

```
nomad_vars/
  postgres.tftpl
  grafana.tftpl
```

Files use a `KEY : VALUE` line format and are templated with `local.vars`:

```
POSTGRES_USER     : postgres
POSTGRES_PASSWORD : ${postgres_password}
POSTGRES_DB       : postgres
```

#### `storage`

This map defines storage type, mount configuration, and volumes for your services.

```hcl
storage = {
  type        = "host"
  mount_point = "/mnt"
  nfs_server  = ""

  volumes = {
    "loki" = {
      volume_id   = "loki"
      external_id = "loki"
      access_mode = "single-node-writer"
    }
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
3.  **Define the Service in `nomad_jobs.auto.tfvars`**: Add your service to the appropriate deployment tier (primary, secondary, or tertiary) in the `nomad_jobs` map.
4.  **Add Nomad Variables (Optional)**: If your service needs secrets or environment variables, create a `nomad_vars/{service}.tftpl` file.
5.  **Add Volumes (Optional)**: If your service needs a volume, add it to the `storage.auto.tfvars` map under `storage.volumes`.
6.  **Deploy**: Run `make deploy-services`.
