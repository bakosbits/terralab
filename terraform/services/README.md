# Terraform Services Deployment

This directory contains the Terraform code for deploying services on top of the Nomad cluster.

## Architecture

This Terraform environment manages the lifecycle of services running on the Nomad cluster. It uses Nomad jobs for running services, Consul KV for storing service configuration files, and Nomad variables for secrets and environment variables.

### Service Deployment Order

Services are deployed in three ordered tiers defined in `var.nomad_jobs.auto.tfvars`. Each tier waits for the previous to complete before starting:

1. **Primary**: Core infrastructure services that other services depend on (networking, storage, databases).
2. **Secondary**: Services that depend on primary services but are dependencies for others.
3. **Tertiary**: Application services that depend on primary and secondary services.

### Service Asset Layout

All assets for a service are co-located in a single directory under `nomad_jobs/`:

```
nomad_jobs/
  gitea/
    gitea.hcl          # Nomad job spec (required)
    volumes.yaml       # Volume definitions (optional)
    gitea.nv.yaml      # Nomad variables / secrets (optional)
    consul_kv/         # Consul KV config files (optional)
      config.yaml
```

| File | Purpose |
|---|---|
| `<service>.hcl` | Nomad job spec, rendered with `templatefile(local.vars)` |
| `volumes.yaml` | Volume definitions registered by `nomad_storage.tf` |
| `<service>.nv.yaml` | Nomad variables at path `nomad/jobs/<service>`, `KEY : VALUE` format |
| `consul_kv/<file>` | Config files stored in Consul KV at `{lab_name}/<service>/<file>` |

All three optional asset types are **auto-discovered** by Terraform — no tfvars entries are needed beyond adding the job name to `var.nomad_jobs`.

## Configuration

### `*.auto.tfvars` files

| File | Purpose |
|---|---|
| `var.services.auto.tfvars` | `env` map: template variables, provider addresses, credentials |
| `var.nomad_jobs.auto.tfvars` | `nomad_jobs` map: job names grouped into deployment tiers |

Run `make generate-vars` to produce skeleton templates for both files.

### `var.nomad_jobs.auto.tfvars`

Jobs are referenced by directory name under `nomad_jobs/`. Terraform resolves each entry to `nomad_jobs/{name}/{name}.hcl`. 

### `You have the option of stacking jobs into deployment buckets to address dependencies`

```hcl
nomad_jobs = {
  primary = {
    jobs = [
      "traefik",
      "docker_registry",
      "influxdb",
      "postgres",
    ]
  }
  secondary = {
    jobs = [
      "grafana",
      "prometheus",
    ]
  }
  tertiary = {
    jobs = [
      "gitea",
      "jellyfin",
    ]
  }
}
```

### `volumes.yaml`

Volume definitions live in each job's directory. Terraform auto-discovers them and registers the volumes with Nomad before deploying jobs.

```yaml
gitea:
  volume_id: gitea
  external_id: gitea
  access_mode: single-node-writer
  nodes: null
```

**Volume naming convention**: a hyphen in the volume name is a path separator — the first hyphen becomes `/` in `external_id`. This is applied automatically by `make generate-vars`.

```yaml
media-downloads:          # volume name used in HCL source/volume_mount
  volume_id: media-downloads
  external_id: media/downloads   # ← first hyphen → /
  access_mode: single-node-writer
  nodes: null
```

`storage_type` and `mount_point` are configured in `var.services.auto.tfvars` under the `env` map (defaults: `host`, `/mnt`).

### `<service>.nv.yaml`

Nomad variables (secrets, environment variables) stored at `nomad/jobs/<service>`. Each line is `KEY : VALUE`. The file is rendered with `templatefile()` first, so `${var}` substitution from `local.vars` works.

```
POSTGRES_USER     : postgres
POSTGRES_PASSWORD : ${postgres_password}
POSTGRES_DB       : postgres
```

### `consul_kv/<file>`

Configuration files placed in `nomad_jobs/<service>/consul_kv/` are automatically stored in Consul KV at `{lab_name}/<service>/<file>`. Files are rendered with `templatefile(local.vars)`.

```
nomad_jobs/traefik/consul_kv/traefik.yaml    → {lab_name}/traefik/traefik.yaml
nomad_jobs/traefik/consul_kv/dynamic.yaml   → {lab_name}/traefik/dynamic.yaml
```

## Deployment

```bash
make init-services    # terraform init
make plan-services    # terraform plan
make deploy-services  # terraform apply --auto-approve
```

## How to Add a New Service

1. Create `nomad_jobs/<name>/<name>.hcl` using `${var}` template variables from `local.vars`.
2. Optionally add `nomad_jobs/<name>/consul_kv/<config_file>` for configuration files.
3. Optionally add `nomad_jobs/<name>/<name>.nv.yaml` for secrets/env vars.
4. Optionally add `nomad_jobs/<name>/volumes.yaml` for volumes (or run `make generate-vars` to scaffold it).
5. Add `"<name>"` to the correct tier in `var.nomad_jobs.auto.tfvars`.
6. Run `make deploy-services`.
